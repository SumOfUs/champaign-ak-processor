class SurveyResponseProcessor
  class Error < StandardError; end

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.to_h
  end

  def run
    if new_action?
      create_new_action
    elsif member_email_changed?
      delete_existing_action
      create_new_action
    else
      update_action
    end
  end

  private

  def new_action?
    ak_action.blank?
  end

  def member_email_changed?
    @params[:params][:email] != ak_action[:member_email]
  end

  def create_new_action
    ActionCreator.run(create_params)
  end

  def update_action
    response = Ak::Client.client.update_petition_action(ak_action[:ak_id], update_params)
    if !response.success?
      raise Error.new("Error while updating AK action. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  def delete_existing_action
    response = Ak::Client.client.delete_action(ak_action[:ak_id])
    if !response.success?
      raise Error.new("Error while deleting AK action. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    ActionRepository.delete(@params[:meta][:action_id])
  end

  def ak_action
    @ak_action ||= ActionRepository.get(@params[:meta][:action_id])
  end

  # AK's API has an inconsistent format when it comes to creating vs updating actions with custom fields.
  # * On creation: To pass a custom field it must be passed as a regular field prepending the `action_*` prefix.
  # example: { action_my_field: 'hello world' }
  # * On update: To pass a custom field it must be passed as a json object on the `fields` key.
  # example: { fields: { my_field: 'hello world' }
  #
  # We're also prepending the `survey_` prefix to all custom fields.
  def update_params
    params = @params[:params].clone
    params[:page] = ak_action[:page_ak_uri]

    # Move all params prefixed with `action_` to
    # the fields key and remove the prefix
    action_params = {}
    params.each do |key, val|
      if key =~ /\Aaction_.*/
        new_key = key.gsub(/\Aaction_/, '')
        action_params["survey_#{new_key}"] = val
      end
    end
    params[:fields] = action_params

    params
  end

  # Replace `action_` prefix with `action_survey_` prefix
  def create_params
    params = @params.clone
    params[:params] = params[:params].clone

    action_keys = params[:params].select {|key, val| key =~ /\Aaction_.*/ }
    action_keys.each do |key, val|
      new_key = key.gsub(/\Aaction_/, "action_survey_")
      params[:params][new_key] = val
      params[:params].delete(key)
    end

    params
  end
end
