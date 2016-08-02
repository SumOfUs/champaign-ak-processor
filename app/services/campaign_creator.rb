class CampaignCreator
  class Error < StandardError; end
  include Ak::Client

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.slice(:name)
  end

  def run
    client.create_multilingual_campaign(@params).tap do |response|
      if response.code != 201
        raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
      end
    end
  end
end
