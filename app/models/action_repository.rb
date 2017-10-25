class ActionRepository
  class NotFoundError < StandardError; end

  EXPIRATION_IN_SECONDS = 10 * 60

  # ch_id => champaign id
  # ak id => action_kit id
  def self.set(ch_id, ak_id:, page_ak_uri:, member_email:)
    key = "action:#{ch_id}"
    redis.hmset(key, :ak_id, ak_id, :page_ak_uri, page_ak_uri, :member_email, member_email)
    redis.expire key, EXPIRATION_IN_SECONDS
  end

  def self.get(ch_id)
    redis.hgetall("action:#{ch_id}").symbolize_keys!
  end

  def self.get!(ch_id)
    action = get(ch_id)
    if action.empty?
      raise NotFoundError.new("Can't find action with id: #{ch_id}")
    end
    action
  end

  def self.delete(ch_id)
    redis.del("action:#{ch_id}")
  end

  def self.redis
    RedisClient.client
  end
end
