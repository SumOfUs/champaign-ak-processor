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
     ActionCreator.run(@params)
   else
     update_action
   end
  end

  private

  def update_action
    response = Ak::Client.client.update_petition_action(existing_action_ak_id, @params[:params])
    if !response.success?
      raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  def new_action?
    existing_action_ak_id.blank?
  end

  def existing_action_ak_id
    @existing_action_ak_id ||= begin
      resource_uri = ActionRepository.get(@params[:meta][:action_id])
      if resource_uri.present?
        ActionKitConnector::Util.extract_id_from_resource_uri(resource_uri)
      end
    end
  end
end
