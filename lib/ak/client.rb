module Ak
  module Client
    module_function

    def client
      @client ||= ActionKitConnector::Client.new do |c|
        c.username = ENV['AK_USERNAME']
        c.password = ENV['AK_PASSWORD']
        c.host     = ENV['AK_HOST']
      end
    end
  end
end

