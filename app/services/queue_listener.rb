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
  NEW_CALL = 'new_call'
  UPDATE_CALL = 'update_call'
  RECURRING_PAYMENT_UPDATE = 'recurring_payment_update'

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGES
        PageUpdater.run(params)

      when CREATE_PAGES
        PageCreator.run(params[:params])

      when CREATE_ACTION
        ActionCreator.run(action_params(params))

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

      when RECURRING_PAYMENT_UPDATE
        update_recurring_payment(params)

      when NEW_CALL
        CallCreator.run(params)

      when UPDATE_CALL
        CallUpdater.run(params)

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
    res = client.create_recurring_payment(params[:params])
    unless res.success?
      raise Error.new("Managing recurring subscription payment failed with #{res.parsed_response['errors']}!")
    end
    res
  end

  def subscribe_member(params)
    language = params[:params][:locale].try(:upcase)
    page_name = ENV["AK_SUBSCRIPTION_PAGE_#{language}"] || ENV['AK_SUBSCRIPTION_PAGE_EN']
    unset_message = "Your ActionKit page for subscriptions from the home page has not been set for locales '#{language}' or 'EN'"
    raise Error.new(unset_message) if page_name.blank?
    res = client.create_action(action_params(params)[:params].merge({ page: page_name }))
    raise Error.new("Member subscription failed with #{res.parsed_response['errors']}!") unless res.success?
    res
  end

  def update_member(params)
    res = client.update_user(params[:params]["akid"], params[:params])
    unless res.success?
      raise Error.new("Member update failed with #{res.parsed_response["errors"]}!")
    end
  end

  def update_recurring_payment(params)
    res = client.update_recurring_payment(params[:params])
    unless res.success?
      raise Error.new("Updating recurring payment failed with #{res.parsed_response['errors']}")
    end
  end

  def action_params(params)
    country = params[:params][:country]
    raise Error.new("Generic action processing attempted without a country in the request.") unless country.present?
    if country == "United States" && ENV['BYPASS_ZIP_VALIDATION']
      raise Error.new("Your default US zip code has not been set!") unless ENV['DEFAULT_US_ZIP'].present?
      params[:params][:postal] = verify_zip(params[:params][:postal])
    end
    params
  end

  def verify_zip(postal)
    first_five = postal[0,5]
    return ENV['DEFAULT_US_ZIP'] unless is_valid_zip(first_five)
    first_five
  end

  def is_valid_zip(postal)
    # Postal is an integer written as a string and five characters long
    postal =~ /\A\d{5}\Z/
  end

end
