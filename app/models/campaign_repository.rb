class CampaignRepository
  def self.set(ch_campaign_id, ak_campaign_id)
    redis.set("campaign:#{ch_campaign_id}", ak_campaign_id)
  end

  def self.get(ch_campaign_id)
    redis.get("campaign:#{ch_campaign_id}")
  end

  def self.redis
    RedisClient.client
  end
end
