module Ak
  def Ak.client
    @client ||= ActionKitConnector::Connector.new(
      ENV['AK_USERNAME'],
      ENV['AK_PASSWORD'],
      ENV['AK_HOST']
    )
  end
end

class AkActionCreator < AkCreator
  class << self
    def create_action(params)
      Ak.client.create_action(params)
    end
  end
end

