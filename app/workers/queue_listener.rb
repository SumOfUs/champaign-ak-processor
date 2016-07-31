class QueueListener
  include Ak::Client

  CREATE_PAGES    = 'create'
  CREATE_ACTION   = 'action'
  CREATE_DONATION = 'donation'
  UPDATE_PAGES    = 'update_pages'
  SUBSCRIPTION_PAYMENT = 'subscription-payment'
  SUBSCRIBE_MEMBER = 'subscribe_member'
  CREATE_CAMPAIGN = 'create_campaign'

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGES
        update_pages(params)

      when CREATE_PAGES
        create_pages( params[:params] )

      when CREATE_ACTION
        create_action(params)

      when CREATE_DONATION
        create_donation(params)

      when SUBSCRIPTION_PAYMENT
        create_payment(params)

      when SUBSCRIBE_MEMBER
        subscribe_member(params)

      when CREATE_CAMPAIGN
        CampaignCreator.run(params)

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

  def create_action(params)
    params[:params][:mailing_id] = extract_mailing_id(params[:params][:akid])

    action = Action.find_by_id(params[:meta][:action_id])
    response = client.create_action(params[:params])
    payload = params[:meta].merge(type: 'petition')

    if action
      action[:form_data][:ak_resource_id] = response['resource_uri']
      action.save
    end

    Broadcast.emit(payload)
    ActionsCache.append(payload)
    response
  end

  def create_donation(params)
    order = params[:params][:order]
    action = Action.find_by_id(params[:meta][:action_id])
    response = client.create_donation(params[:params])

    if action
      action[:form_data][:ak_resource_id] = response['resource_uri']
      action.save
    end

    Broadcast.emit( params[:meta].merge(type: 'donation', amount: order[:amount], currency: order[:currency] ) )
    response
  end

  def create_payment(params)
    client.create_recurring_payment(params[:params])
  end

  def subscribe_member(params)
    page_name = ENV['AK_SUBSCRIPTION_PAGE_NAME']
    if page_name.blank?
      Rails.logger.error("Your ActionKit page for subscriptions from the home page has not been set!")
    else
      client.create_action(params[:params].merge({ page: page_name }))
    end
  end

  def create_pages(params)
    AkPageCreator.create_page(params.merge(page_type: 'petition'))
    AkPageCreator.create_page(params.merge(page_type: 'donation'))
  end

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end
end
