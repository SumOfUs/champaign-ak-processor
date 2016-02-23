require "net/http"
require "uri"

class ShareAnalyticsUpdater
  def self.update_shares
    new(nil).update_collection
  end

  def initialize(collection)
    #Collection can be passed explicitly in order to reuse this task to update only a section of buttons at a later time.
    @collection = collection || Share::Button.all
    @uri = URI.parse('http://run.shareprogress.org/api/v1/buttons/analytics')
    @sp_api_key = ENV['SHARE_PROGRESS_API_KEY']
  end

  def update_collection
    update_shares
  end

  private

  def update_shares
    @collection.each do |button|
      begin
        request_analytics_from_sp(button)
      rescue ::ShareProgressApiError
        puts $!.message
        next
      end
    end
  end

  def request_analytics_from_sp(button)
    response = Net::HTTP.post_form(@uri, {key: @sp_api_key, id: button.sp_id})
    raise_or_update(response, button)
  end

  def raise_or_update(response, button)
    parsed_body = JSON.parse(response.body).with_indifferent_access
    if parsed_body[:success]
      Rails.logger.debug "SharePogress Response: #{parsed_body}"
      button.update!(analytics: response.body )
    else
      raise ::ShareProgressApiError, "ShareProgress button analytics update failed with the following message from their API: #{parsed_body[:message]}."
    end
  end
end
