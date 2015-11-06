class AkCreator

  # Expose this both for testing and for easy access in case someone needs to do direct connections.
  attr_reader :connection

  def initialize
  end

  def client
    @client ||= ActionKitConnector::Connector.new(ENV['AK_USERNAME'],  ENV['AK_PASSWORD'],  ENV['AK_HOST'])
  end
end

