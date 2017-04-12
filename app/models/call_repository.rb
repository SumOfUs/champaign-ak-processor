class CallRepository
  class NotFoundError < StandardError; end

  # ch_id => champaign id
  # ak_id => action_kit id
  def self.set(ch_id, ak_id)
    redis.set("call:#{ch_id}", ak_id)
  end

  def self.get(ch_id)
    redis.get("call:#{ch_id}")
  end

  def self.get!(ch_id)
    get(ch_id) || raise(NotFoundError.new "Can't find repository with id: #{ch_id}")
  end

  def self.delete(ch_id)
    redis.del("call:#{ch_id}")
  end

  def self.redis
    RedisClient.client
  end
end
