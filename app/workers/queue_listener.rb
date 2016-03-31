class QueueListener
  include Ak::Client

  CREATE_PAGES    = 'create'
  CREATE_ACTION   = 'action'
  CREATE_DONATION = 'donation'
  UPDATE_PAGES    = 'update_pages'

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
      else
        raise ArgumentError, "Unsupported message type: #{params[:type]}"
    end
  end

  def update_pages(params)
    data = params[:params]
    data.delete(:name)

    client.update_petition_page(
      data.merge({
        id: petition_id(params)
      }.tap do |load|
          load[:title] = suffix_title(data[:title], 'petition') if data[:title]
        end
      )
    )

    client.update_donation_page(
      data.merge({
        id: donation_id(params)
      }.tap do |load|
        load[:title] = suffix_title(data[:title], 'donation') if data[:title]
      end
      )
    )
  end

  private

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
    id = (uri || '').match(/(\d+)\/$/){|m| m[1] if m }
    raise ArgumentError, "Missing resource URI for page" if id.blank?
    id
  end

  def create_action(params)
    data = params[:params]
    data[:mailing_id] = extract_mailing_id(data[:akid])
    client.create_action(data)
  end

  def create_donation(params)
    data = params[:params]
    client.create_donation(data)
  end

  def create_pages(params)
    AkPageCreator.create_page(params.merge(page_type: 'petition'))
    AkPageCreator.create_page(params.merge(page_type: 'donation'))
  end

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end
end

