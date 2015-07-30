class AkCreator
  def initialize(host, username, password)
    @connection = ActionKitConnector::Connector.new username, password, host
  end
end
