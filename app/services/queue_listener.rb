class QueueListener
  include Ak::Client
  class Error < StandardError; end

  CREATE_PAGES    = 'create'
  CREATE_ACTION   = 'action'
  CREATE_DONATION = 'donation'
  UPDATE_PAGES    = 'update_pages'
  SUBSCRIPTION_PAYMENT = 'subscription-payment'
  SUBSCRIPTION_CANCELLATION = 'cancel_subscription'
  SUBSCRIBE_MEMBER = 'subscribe_member'
  CREATE_CAMPAIGN = 'create_campaign'
  UPDATE_CAMPAIGN = 'update_campaign'
  UPDATE_MEMBER = 'update_member'
  NEW_SURVEY_RESPONSE = 'new_survey_response'

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGES
        PageUpdater.run(params)

      when CREATE_PAGES
        PageCreator.run(params[:params])

      when CREATE_ACTION
        ActionCreator.run(params)

      when CREATE_DONATION
        create_donation(params)

      when SUBSCRIPTION_PAYMENT
        create_payment(params)

      when SUBSCRIBE_MEMBER
        subscribe_member(params)

      when CREATE_CAMPAIGN
        CampaignCreator.run(params)

      when UPDATE_CAMPAIGN
        CampaignUpdater.run(params)

      when UPDATE_MEMBER
        update_member(params)

      when SUBSCRIPTION_CANCELLATION
        cancel_subscription(params[:params])

      when NEW_SURVEY_RESPONSE
        SurveyResponseProcessor.run(params)

      else
        raise ArgumentError, "Unsupported message type: #{params[:type]}"
    end
  end

  private

  def cancel_subscription(params)
    res = client.cancel_subscription(params)
    unless res.success?
      raise Error.new("Marking recurring donation cancelled failed. HTTP Response code: #{res.code}, body: #{res.body}")
    end
  end

  def create_donation(params)
    order = params[:params][:order]
    action = Action.find_by_id(params[:meta][:action_id])
    response = client.create_donation(params[:params])

    if action
      action[:form_data][:ak_resource_id] = response['resource_uri']
      action.save
    end

    Broadcast.emit( params[:meta].merge(type: 'donation', amount: order[:amount], currency: order[:currency] ) )
    response
  end

  def create_payment(params)
    client.create_recurring_payment(params[:params])
  end

  def subscribe_member(params)
    language = params[:params][:locale].try(:upcase)
    page_name = ENV["AK_SUBSCRIPTION_PAGE_#{language}"] || ENV['AK_SUBSCRIPTION_PAGE_EN']
    unset_message = "Your ActionKit page for subscriptions from the home page has not been set for locales '#{language}' or 'EN'"
    raise Error.new(unset_message) if page_name.blank?
    res = client.create_action(params[:params].merge({ page: page_name }))
    raise Error.new("Member subscription failed with #{res.parsed_response['errors']}!") unless res.success?
    res
  end

  def update_member(params)
    res = client.update_user(params[:params]["akid"], params[:params])
    unless res.success?
      raise Error.new("Member update failed with #{res.parsed_response["errors"]}!")
    end
  end
end
