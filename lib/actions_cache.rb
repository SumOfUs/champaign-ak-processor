module ActionsCache

  def self.append(payload)
    @store ||= ActionsCache::Store.new(ENV['ACTIONS_CACHE_SIZE'].to_i)
    @store.append(payload)
  end

  # ActionsCache::Store can
  class Store
    attr_accessor :redis
    attr_accessor :cache_size
    attr_accessor :namespace

    def initialize(cache_size = 100, namespace = 'champaign:actions:cache')
      @redis = RedisClient.client
      @cache_size = cache_size
      @namespace = namespace
    end

    # Append an item to the set and respect @cache_size (deletes extra)
    def append(payload)
      result = redis.zadd(namespace, Time.now.to_i, payload.to_json)
      remrange(0, ((cache_size + 1) * -1))
      result
    end

    # Utility method to remove items by rank
    def remrange(from, to)
      result = redis.zremrangebyrank(namespace, from, to)
      result
    end

    # Clear the entire ordered set
    def clear
      remrange(0, -1)
    end

    def actions
      actions = redis.zrange(namespace, 0, -1)
      actions
    end

  end
end
