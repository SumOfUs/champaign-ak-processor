class QueueListener
  include Ak::Client

  CREATE_PAGES    = 'create'
  CREATE_ACTION   = 'action'
  CREATE_DONATION = 'donation'
  UPDATE_PAGES    = 'update_pages'
  SUBSCRIPTION_PAYMENT = 'subscription-payment'

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGES
        update_pages(params)

      when CREATE_PAGES
        create_pages( params[:params] )

      when CREATE_ACTION
        create_action(params[:params])

      when CREATE_DONATION
        create_donation(params[:params])

      when SUBSCRIPTION_PAYMENT
        create_payment(params)
      else
        raise ArgumentError, "Unsupported message type: #{params[:type]}"
    end
  end

  def update_pages(params)
    data = params[:params]
    data.delete(:name)

    raise ArgumentError, "Missing resource URI for page" if params[:petition_uri].blank? and params[:donation_uri].blank?

    unless params[:petition_uri].blank?
      client.update_petition_page(add_title_and_id(data, params, 'petition'))
    end

    unless params[:donation_uri].blank?
      client.update_donation_page(add_title_and_id(data, params, 'donation'))
    end
  end

  private

  def add_title_and_id(data, params, suffix)
    data.merge({
      id: suffix.inquiry.donation? ? donation_id(params) : petition_id(params)
    }.tap do |load|
        load[:title] = suffix_title(data[:title], suffix) if data[:title]
      end
    )
  end

  def suffix_title(title, type)
    return title if title.strip =~ %r{(#{type.capitalize})}
    "#{title} (#{type.capitalize})"
  end

  def petition_id(params)
    extract_id(params[:petition_uri])
  end

  def donation_id(params)
    extract_id(params[:donation_uri])
  end

  def extract_id(uri)
    (uri || '').match(/(\d+)\/$/){|m| m[1] if m }
  end

  def create_action(data)
    data[:mailing_id] = extract_mailing_id(data[:akid])
    response = client.create_action(data)
    Broadcast.emit( action_data(type: :petition, data: data) )
    response
  end

  def action_data(type:, data:)
    {
      type:       type,
      name:       data[:name],
      page_id:    data[:page_id],
      source:     data[:source],
      country:    data[:country],
      referer:    data[:action_referer],
      amount:     data[:amount],
      currency:   data[:currency],
      created_at: Time.now.to_i
    }
  end

  def create_donation(data)
    response = client.create_donation(data)
    Broadcast.emit( action_data(type: :donation, data: data) )
    response
  end

  def create_payment(params)
    client.create_recurring_payment(params[:params])
  end

  def create_pages(params)
    AkPageCreator.create_page(params.merge(page_type: 'petition'))
    AkPageCreator.create_page(params.merge(page_type: 'donation'))
  end

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end
end

#
# name: 'Omar',
# country: 'United Kingdom',
# time: '12 Dec 13:23',
# action_type: 'donation|petition',
# meta: { amount: 12 },
# page: {title: 'Foo Bar', slug: 'foo-bar', url: '/a/foo-bar'}

#
#
# 10:01
#   1,2,3,4,5,6
# 10:02
#   7,8,9,10
# 10:03
#   
#
#
#pages:12 = { title: 'foo bar', slug: 'foo-bar' }
#countries: {1: 'unitked kingdom' }
