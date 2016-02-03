require "net/http"
require "uri"

class ShareAnalyticsUpdater
  def self.update_shares
    puts "Fetching data..."

    Share::Button.all.each do |button|
      uri = 'http://run.shareprogress.org/api/v1/buttons/analytics'
      uri = URI.parse(uri)

      response = Net::HTTP.post_form(uri, {key: ENV['SHARE_PROGRESS_API_KEY'], id: button.sp_id})
      if response.success?
        button.update(analytics: response.body )
      end
    end

    puts "Fetching has completed."
  end
end
