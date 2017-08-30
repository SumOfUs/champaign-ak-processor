class QueueListener
  include Ak::Client
  class Error < StandardError; end

  def perform(sqs_message, params)
    case params[:type]
      when 'update_pages', 'page:update'
        PageUpdater.run(params)

      when 'create', 'page:new'
        PageCreator.run(params[:params])

      when 'action', 'action:new'
        ActionCreator.run(action_params(params))

      when 'donation', 'donation:new'
        create_donation(params)

      when 'subscription-payment', 'subscription-payment:new'
        create_payment(params)

      when 'subscribe_member', 'member-subscription:new'
        subscribe_member(params)

      when 'create_campaign', 'campaign:new'
        CampaignCreator.run(params)

      when 'update_campaign', 'campaign:update'
        CampaignUpdater.run(params)

      when 'update_member', 'member:update'
        update_member(params)

      when 'cancel_subscription', 'subscription:cancel'
        cancel_subscription(params[:params])

      when 'new_survey_response', 'survey-response:new'
        SurveyResponseProcessor.run(params)

      when 'recurring_payment_update', 'recurring-payment:update'
        update_recurring_payment(params)

      when 'new_call', 'call:new'
        ActionCreator.run(params)

      when 'update_call', 'call:update'
        ActionUpdater.run(params)

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
      raise Error.new("Managing recurring subscription payment failed with:\n #{res.parsed_response}")
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
