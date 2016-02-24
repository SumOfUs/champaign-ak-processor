class MessageHandlerController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle
    response = QueueListener.new.perform(nil, params)
    render json: response, status: 200
  end

  def dispatch_shareprogress_update
    ShareAnalyticsUpdater.enqueue_jobs
    render nothing: true, status: 200
  end
end

