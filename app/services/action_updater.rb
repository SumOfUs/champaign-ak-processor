class ActionUpdater
  class Error < StandardError; end

  def self.run(*params)
    new(*params).run
  end

  def initialize(action_ak_id, params)
    @ak_id = action_ak_id
    @params = params
  end

  def run
    response = Ak::Client.client.update_petition_action(@ak_id, update_params)
    if !response.success?
      raise Error.new("Error while updating AK action. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  private

  def update_params
    update_params = sanitize_action_fields(@params[:params])
    update_params[:fields] = flatten_nested_params(update_params[:fields])
    # AK responds with an error if we send this param, removing it in case it's present
    update_params.delete(:page)
    update_params
  end

  # AK's API has an inconsistent format when it comes to creating vs updating actions with custom fields.
  # * On creation: To pass a custom field it must be passed as a regular field prepending the `action_*` prefix.
  # example: { action_my_field: 'hello world' }
  # * On update: To pass a custom field it must be passed as a json object on the `fields` key.
  # example: { fields: { my_field: 'hello world' }
  def sanitize_action_fields(params)
    params = params.clone
    action_params = {}
    params.each do |key, val|
      if key =~ /\Aaction_.*/
        new_key = key.gsub(/\Aaction_/, '')
        action_params[new_key] = val
      end
    end
    params.delete_if do |key, val|
      key =~ /\Aaction_.*/
    end

    params[:fields] = action_params
    params
  end

  # AK doesn't handle well nested json objects, that's why we flatten them here
  def flatten_nested_params(params)
    flat_params = params.clone
    params.each do |key, val|
      if val.is_a?(Hash)
        val.each do |inner_key, inner_val|
          flat_params["#{key}_#{inner_key}"] = inner_val.to_s
        end
        flat_params.delete(key)
      end
    end
    flat_params
  end
end