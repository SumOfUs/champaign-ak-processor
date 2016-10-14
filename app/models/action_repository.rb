class ActionRepository
  class NotFoundError < StandardError; end

  # ch_id => champaign id
  # ak id => action_kit id
  def self.set(ch_id, ak_id:, page_ak_id:)
    redis.hmset("action:#{ch_id}", :ak_id, ak_id, :page_ak_id, page_ak_id)
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

  def self.redis
    RedisClient.client
  end
end
