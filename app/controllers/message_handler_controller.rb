class MessageHandlerController < ApplicationController
  skip_before_action :verify_authenticity_token
  def handle
    # We bump handling the message off to the same class than handles
    # reading the contents directly off of SQS in the first place.
    # This allows us to aggregate the logic and run the same code
    # regardless of whether we're doing a `bundle exec` call or we're
    # getting the messages fed to us by SQS via POST to this HTTP endpoint
    # as is the standard for the Worker Tier in Elastic Beanstalk.
    QueueListener.new.perform(nil, params)
    
    # Tell SQS everything went hunky dory and we can delete the message.
    render nothing: true, status: 200
  end
end
