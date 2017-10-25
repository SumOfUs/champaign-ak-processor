class CampaignRepository
  class NotFoundError < StandardError; end

  EXPIRATION_IN_SECONDS = 10 * 60

  def self.set(ch_campaign_id, ak_campaign_id)
    key = "campaign:#{ch_campaign_id}"
    redis.set(key, ak_campaign_id)
    redis.expire key, EXPIRATION_IN_SECONDS
  end

  def self.get(ch_campaign_id)
    redis.get("campaign:#{ch_campaign_id}")
  end

  def self.get!(ch_campaign_id)
    get(ch_campaign_id) || raise(NotFoundError.new "Can't find campaign with id: #{ch_campaign_id}")
  end

  def self.redis
    RedisClient.client
  end
end
