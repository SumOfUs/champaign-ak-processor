class ShareAnalyticsUpdater
  include HTTParty
  def self.dispatch_update
    response = HTTParty.get("#{champaign_url}/api/update_share_analytics")
    render nothing: true, status: response.code
  end
end
