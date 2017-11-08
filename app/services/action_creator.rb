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
    params[:params][:referring_mailing_id] = extract_mailing_id(params[:params][:referring_akid])

    response = client.create_action(params[:params])
    if !response.success?
      raise Error.new("Error while creating AK action. HTTP Response code: #{response.code}, body: #{response.body}")
    end

    if params[:meta][:action_id].present?
      ak_id = ActionKitConnector::Util.extract_id_from_resource_uri(response['resource_uri'])
      ActionRepository.set(params[:meta][:action_id],
                           ak_id: ak_id,
                           page_ak_uri: response.parsed_response['page'],
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
