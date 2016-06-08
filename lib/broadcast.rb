class Broadcast
  def self.emit(data)
    RedisClient.client.publish('actions', data.to_json)
  end
end
