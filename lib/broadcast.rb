class Broadcast
  def self.emit(data)
    RedisClient.client.publish('champaign:actions', data.to_json)
  end
end
