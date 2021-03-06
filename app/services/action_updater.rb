# frozen_string_literal: true

class ActionUpdater
  class Error < StandardError; end

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    ak_id = ActionRepository.get!(@params[:meta][:action_id])[:ak_id]
    response = Ak::Client.client.update_petition_action(ak_id, update_params)
    unless response.success?
      raise Error, "Error while updating AK action. HTTP Response code: #{response.code}, body: #{response.body}"
    end

    response
  end

  private

  def update_params
    update_params = sanitize_action_fields(@params[:params])
    if update_params[:fields].present?
      update_params[:fields] = flatten_nested_params(update_params[:fields])
    end
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
    params = params.to_h.with_indifferent_access
    action_params = {}
    params.each do |key, val|
      if /^action_.*/.match?(key)
        new_key = key.gsub(/^action_/, '')
        action_params[new_key] = val
      end
    end
    params.delete_if do |key, _val|
      key =~ /^action_.*/
    end

    params[:fields] = action_params if action_params.any?
    params
  end

  # AK doesn't handle well nested json objects, that's why we flatten them here
  def flatten_nested_params(params)
    flat_params = params.clone
    params.each do |key, val|
      next unless val.is_a?(Hash)

      val.each do |inner_key, inner_val|
        flat_params["#{key}_#{inner_key}"] = inner_val.to_s
      end
      flat_params.delete(key)
    end
    flat_params
  end
end
