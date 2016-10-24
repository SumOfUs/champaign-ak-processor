class SurveyResponseProcessor
  class Error < StandardError; end

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
   if new_action?
     ActionCreator.run(create_params)
   else
     update_action
   end
  end

  private

  def new_action?
    ak_action.blank?
  end

  def update_action
    response = Ak::Client.client.update_petition_action(existing_action_ak_id, update_params)
    if !response.success?
      raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  def existing_action_ak_id
    @existing_action_ak_id ||=
      ActionKitConnector::Util.extract_id_from_resource_uri(ak_action[:ak_id])
  end

  def ak_action
    @ak_action ||= ActionRepository.get(@params[:meta][:action_id])
  end

  # AK's API has an inconsistent format when it comes to creating vs updating actions with custom fields.
  # * On creation: To pass a custom field it must be passed as a regular field prepending the `action_*` prefix.
  # example: { action_my_field: 'hello world' }
  # * On update: To pass a custom field it must be passed as a json object on the `fields` key.
  # example: { field: { my_field: 'hello world' }
  #
  # We're also prepending the `survey_` prefix to all custom fields.

  def update_params
    params = @params[:params].clone
    params[:page] = @ak_action[:page_ak_id]

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
