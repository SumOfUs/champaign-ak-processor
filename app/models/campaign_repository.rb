class CampaignRepository
  class NotFoundError < StandardError; end

  def self.set(ch_campaign_id, ak_campaign_id)
    redis.set("campaign:#{ch_campaign_id}", ak_campaign_id)
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
