module Ak
  module Client
    def client
      @client ||= ActionKitConnector::Connector.new(ENV['AK_USERNAME'],  ENV['AK_PASSWORD'],  ENV['AK_HOST'])
    end
  end
end

