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
     # Updating action after just creating it since the
     # the `fields` key is not being recorded in AK on creation,
     # it only stores them on update requsts.
     SurveyResponseProcessor.run(@params)
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

  def update_params
    @params[:params].clone.tap do |p|
      p[:page] = @ak_action[:page_ak_id]
    end
  end
end
