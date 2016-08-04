class CampaignUpdater
  class Error < StandardError; end
  include Ak::Client

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.slice(:name)
    @campaign_id = params[:campaign_id] || raise(ArgumentError)
  end

  def run
    ak_campaign_uri = CampaignRepository.get!(@campaign_id)
    ak_campaign_id = ActionKitConnector::Util.extract_id_from_resource_uri(ak_campaign_uri)

    client.update_multilingual_campaign(ak_campaign_id, @params).tap do |response|
      if !response.success?
        raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
      end
    end
  end
end
