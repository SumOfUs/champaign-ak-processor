require 'rails_helper'
require 'redis'

class ActionCache
  KEYS = {
    donation: 'champaign:donations:latest',
    actions:  'champaign:actions:latest',
    all:      'chamapgin:all:latest'
  }

  class << self
    def latest_actions
      client.zrevrange("champaign:actions:latest", 0, 10).map{|a| JSON.parse(a) }
    end

    def client
      @client ||= Redis.new
    end
  end
end

class ActionCache
  module View
    module Viewable
      def initialize(data)
        @data = data
      end
    end

    class Donation
      include Viewable

      def to_builder
        Jbuilder.new do |donation|
        end
      end
    end

    class Action
      include Viewable

      def to_json
        {
          name: 'omar'
        }.to_json
      end
    end
  end
end

class ActionCache
  class Store
    class << self
      def save(type:, data:)
        key = ActionCache::KEYS["#{type}s".to_sym]

        ActionCache.client.zadd(
          key, data[:time].to_i,
          "ActionCache::View::#{type.to_s.classify}".constantize.new(data).to_json
        )

        #ActionCache.client.zadd(key, action[:time].to_i, action.to_json)
        ActionCache.client.zremrangebyrank(key, 0, -1000)
      end
    end
  end
end


describe ActionCache do
  subject { ActionCache }

  before do
    ActionCache.client.flushdb
  end

  before do
    5.times do |i|
      action = {
        id: i + 1,
        time: (Time.now + i.seconds).to_i,
        type: 'p',
        page: { title: "Foo Bar", slug: "foo-bar" },
        member: { name: 'A Lowe' }
      }

      ActionCache::Store.save({
        type: :action,
        data: action
      })
    end
  end

  it 'gets latest actions' do
    expect(
      ActionCache.latest_actions
    ).to eq([
      {id: 1234}
    ])
  end

  xit 'trims to 1000' do
    1100.times do |i|
      ActionCache::Store.save_action({id: i})
    end

    expect(ActionCache.client.zcard("champaign:actions:latest")).to eq(1000)
  end
end
