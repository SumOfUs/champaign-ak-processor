require 'redis'

module RedisClient
  def self.client
    @client ||= Redis.new(
      host: ENV["REDIS_URI"],
      port: ENV["REDIS_PORT"]
    )
  end

  def self.namespace=(namespace)
    @client = Redis::Namespace.new(namespace, redis: client)
  end
end
