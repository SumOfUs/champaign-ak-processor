class CallCreator
  def self.run(params)
    response = ActionCreator.run(params)
    if response.success?
      id = ActionKitConnector::Util.extract_id_from_resource_uri(response['resource_uri'])
      raise 'Invalid resource_uri returned on response to action creation' unless id.present?
      CallRepository.set(params[:meta][:call_id], id)
    end
  end
end