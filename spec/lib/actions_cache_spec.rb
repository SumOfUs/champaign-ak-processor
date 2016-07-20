require 'rails_helper'

describe ActionsCache::Store do
  describe :initialize do
    it 'sets the redis client instance on initialization' do
      actions_cache = ActionsCache::Store.new
      expect(actions_cache.redis).to be_an_instance_of(Redis)
    end

    it 'defaults to a cache size of 100' do
      actions_cache = ActionsCache::Store.new
      expect(actions_cache.cache_size).to eq(100)
    end

    it 'accepts a cache_size' do
      actions_cache = ActionsCache::Store.new(10)
      expect(actions_cache.cache_size).to eq(10)
    end

    it 'sets a default readable namespace (redis ordered set name)' do
      actions_cache = ActionsCache::Store.new
      expect(actions_cache.namespace).to eq('champaign:actions:cache')
    end
  end

  describe :actions do
    after { ActionsCache::Store.new.clear }

    it 'returns all stored actions' do
      actions_cache = ActionsCache::Store.new
      expect(actions_cache.actions).to be_a_kind_of(Enumerable)
    end

    it 'returns them in chronological order' do
      actions_cache = ActionsCache::Store.new

      3.times do |i|
        actions_cache.append({ item: "##{i}" })
      end

      expect(actions_cache.actions.first).to match(/\#0/)
      expect(actions_cache.actions.last).to match(/\#2/)
    end
  end

  describe :append do
    before do
      @size = 5
      @actions_cache = ActionsCache::Store.new(@size)
      @redis = @actions_cache.redis
      @payload = { foo: 'bar' }
    end

    after { ActionsCache::Store.new.clear }

    it 'adds a payload to an ordered set' do
      @actions_cache.append(@payload)
      expect(@actions_cache.actions.count).to eq(1)
    end

    it 'will trim the set if it exceeds its :cache_size' do
      10.times do |i|
        payload = { foo: "Item ##{i}" }
        @actions_cache.append(payload)
      end

      expect(@actions_cache.actions.count).to eq(5)
    end
  end

  describe :remrange do
    before do
      @actions_cache = ActionsCache::Store.new(10)
      10.times do |i|
        payload = { foo: "Item ##{i}" }
        @actions_cache.append(payload)
      end
    end

    after { @actions_cache.clear }

    it 'removes a range of items from the ordered set' do
      @actions_cache.remrange(0, -2)
      expect(@actions_cache.actions.count).to eq(1)
    end
  end

  describe :clear do
    before do
      @actions_cache = ActionsCache::Store.new(10)
      10.times do |i|
        payload = { foo: "Item ##{i}" }
        @actions_cache.append(payload)
      end
    end

    after { @actions_cache.clear }

    it 'clears the entire set' do
      expect(@actions_cache.actions.count).to eq(10)
      @actions_cache.clear
      expect(@actions_cache.actions.count).to eq(0)
    end
  end
end

