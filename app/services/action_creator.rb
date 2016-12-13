class ActionCreator
  include Ak::Client
  class Error < StandardError; end

  attr_reader :params

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.clone
  end

  def run
    params[:params][:mailing_id] = extract_mailing_id(params[:params][:akid])

    action = Action.find(params[:meta][:action_id])

    response = client.create_action(params[:params])
    if !response.success?
      raise Error.new("Error while creating AK action. HTTP Response code: #{response.code}, body: #{response.body}")
    end

    if action
      action[:form_data][:ak_resource_id] = response['resource_uri']
      action.save!
      ActionRepository.set(params[:meta][:action_id],
                           ak_id: response['resource_uri'],
                           page_ak_id: response.parsed_response['page'],
                           member_email: params[:params][:email])
    end

    payload = params[:meta].merge(type: 'petition')
    Broadcast.emit(payload)
    ActionsCache.append(payload)
    response
  end

  private

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end
end
