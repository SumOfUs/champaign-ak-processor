class CampaignUpdater
  class Error < StandardError; end
  include Ak::Client

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
    @campaign_id = params[:campaign_id] || raise(ArgumentError)
    @retry_count = 0
  end

  def run
    ak_campaign_uri = CampaignRepository.get!(@campaign_id)
    ak_campaign_id = ActionKitConnector::Util.extract_id_from_resource_uri(ak_campaign_uri)

    response = client.update_multilingual_campaign(ak_campaign_id, sanitized_params)
    if response.success?
      response
    elsif name_uniqueness_error?(response)
      @retry_count += 1
      run
    else
      raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
    end
  end

  private

  #DUP name-uniqueness
  def name_uniqueness_error?(response)
    response.code == 409 &&
      response.parsed_response.dig('errors', 'name').grep(/Conflict on unique key 'name'/).any?
  end

  def sanitized_params
    @params.slice(:name).tap do |params|
      if @retry_count > 0
        params[:name] = "#{params[:name]}-#{rand(1000)}"
      end
    end
  end
end
