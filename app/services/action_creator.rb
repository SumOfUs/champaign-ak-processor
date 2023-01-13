# frozen_string_literal: true

class ActionCreator
  include Ak::Client
  class Error < StandardError; end
  class APIError < Error
    def initialize(message, http_response)
      super("#{message}. HTTP Response code: #{http_response.code}, body: #{http_response.body}")
    end
  end

  attr_reader :params

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.clone
  end

  def run
    params[:params][:mailing_id] = extract_mailing_id(params[:params][:akid])

    CountryService.extend_with_local_data(params)
    # This is where we write the action to ActionKit
    response = client.create_action(params[:params])
    unless response.success?
      raise APIError.new('Error while creating AK action', response)
    end
    response_hash = JSON.parse(response.body).with_indifferent_access

    # If this is the first action of the user, update their AKID on the member record on Champaign
    if response_hash[:created_user] && params[:meta][:member_id].present?
      champaign_id = params[:meta][:member_id]
      res = HTTParty.patch("#{ENV['CHAMPAIGN_HOST']}/api/members/#{champaign_id}", {
        body: { akid: extract_user_id(response_hash[:akid]) },
        headers: {"X-Api-Key" => ENV['CHAMPAIGN_API_KEY']}
      })
      raise Error.new(res[:errors]) unless res[:errors].blank?
    end

    ak_id = ::ActionKitConnector::Util.extract_id_from_resource_uri(response['resource_uri'])

    # Nullifying mailing_id if referring_akid is pressent
    if params[:params][:referring_akid].present?
      update_response = client.update_petition_action(ak_id, mailing: nil)
      unless update_response.success?
        raise APIError.new('Error while updating AK action', response)
      end
    end

    if params[:meta][:action_id].present?
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

  def extract_user_id(akid = '')
    (akid.try(:split, '.') || [])[1]
  end
end
