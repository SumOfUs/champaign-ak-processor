class QueueListener
  include Ak::Client

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

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGES
        PageUpdater.run(params)

      when CREATE_PAGES
        PageCreator.run(params[:params])

      when CREATE_ACTION
        create_action(params)

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

      else
        raise ArgumentError, "Unsupported message type: #{params[:type]}"
    end
  end

  private

  def cancel_subscription(params)
    client.cancel_subscription(params)
  end

  def create_action(params)
    params[:params][:mailing_id] = extract_mailing_id(params[:params][:akid])

    action = Action.find_by_id(params[:meta][:action_id])
    response = client.create_action(params[:params])
    payload = params[:meta].merge(type: 'petition')

    if action
      action[:form_data][:ak_resource_id] = response['resource_uri']
      action.save
    end

    Broadcast.emit(payload)
    ActionsCache.append(payload)
    response
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
    page_name = ENV['AK_SUBSCRIPTION_PAGE_NAME']
    if page_name.blank?
      Rails.logger.error("Your ActionKit page for subscriptions from the home page has not been set!")
    else
      client.create_action(params[:params].merge({ page: page_name }))
    end
  end

  def update_member(params)
    res = client.update_user(params[:params]["akid"], params[:params])
    unless res.success?
      Rails.logger.error("Member update failed with #{res.parsed_response["errors"]}!")
    end
  end

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end
end
