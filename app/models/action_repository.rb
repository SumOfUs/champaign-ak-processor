class ActionRepository
  class NotFoundError < StandardError; end

  def self.set(ch_action_id, ak_action_id)
    redis.set("action:#{ch_action_id}", ak_action_id)
  end

  def self.get(ch_action_id)
    redis.get("action:#{ch_action_id}")
  end

  def self.get!(ch_action_id)
    get(ch_action_id) || raise(NotFoundError.new "Can't find action with id: #{ch_action_id}")
  end

  def self.redis
    RedisClient.client
  end
end
