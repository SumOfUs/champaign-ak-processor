class CampaignCreator
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
    client.create_multilingual_campaign(@params).tap do |response|
      if response.success?
        CampaignRepository.set(@campaign_id, response.headers['location'])
      else
        raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
      end
    end
  end
end
