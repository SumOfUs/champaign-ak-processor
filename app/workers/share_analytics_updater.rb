require "net/http"
require "uri"
require 'aws-sdk'

class ShareAnalyticsUpdater
  class << self
    def update_shares
      new.update_collection
    end

    def update_share(share_id)
      new.update_share(share_id)
    end
  end

  def initialize(collection = nil)
    #Collection can be passed explicitly in order to reuse this task to update only a section of buttons at a later time.
    @collection = collection || Share::Button.all
    @uri = URI.parse('http://run.shareprogress.org/api/v1/buttons/analytics')
    @sp_api_key = ENV['SHARE_PROGRESS_API_KEY']
  end

  def update_collection
    update_shares
  end

  def update_share(id)
    share = Share::Button.find id


    if share and share.sp_id.present?
      response = Net::HTTP.post_form(@uri, {key: @sp_api_key, id: share.sp_id})
      raise_or_update(response, share)
    end
  end

  private

  def update_shares
    @collection.each do |button|
      Aws::SQS::Client.new.send_message({
        queue_url:    ENV['SQS_ENDPOINT'],
        message_body: {
          type: 'update_share',
          share_id: button.id
        }
      }.to_json)
    end
  end

  def request_analytics_from_sp(button)
    response = Net::HTTP.post_form(@uri, {key: @sp_api_key, id: button.sp_id})
    raise_or_update(response, button)
  end

  def raise_or_update(response, button)
    begin
      parsed_body = JSON.parse(response.body).with_indifferent_access
      if parsed_body[:success]
        Rails.logger.debug "SharePogress Response: #{parsed_body}"
        button.update!(analytics: response.body )
      else
        raise ::ShareProgressApiError, "ShareProgress button analytics update failed with the following message from their API: #{parsed_body[:message]}."
      end
    rescue => e
      Rails.logger.debug("Something happened #{e.inspect} #{response.body}")
    end
  end
end

