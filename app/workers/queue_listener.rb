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

    client.update_petition_page( data.merge(id: petition_id(params) ))
    client.update_donation_page( data.merge(id: donation_id(params) ))
  end

  private

  def petition_id(params)
    params.fetch(:petition_uri, '').match(/(\d+)\/$/)[1]
  end

  def donation_id(params)
    params.fetch(:donation_uri, '').match(/(\d+)\/$/)[1]
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

  def client
    @client ||= ActionKitConnector::Client.new do |c|
      c.username = ENV['AK_USERNAME']
      c.password = ENV['AK_PASSWORD']
      c.host     = ENV['AK_HOST']
    end
  end
end

