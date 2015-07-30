class AkCreator

  # Expose this both for testing and for easy access in case someone needs to do direct connections.
  attr_reader :connection

  def initialize(host, username, password)
    @connection = ActionKitConnector::Connector.new username, password, host
  end
end
