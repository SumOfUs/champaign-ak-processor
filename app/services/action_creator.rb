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

    # response body looks like this:
    #
    # { "akid": ".15434964.kQEpgE",
    #   "created_at": "2019-11-13T16:29:16.247009",
    #   "created_user": true, "fields": {}, "id": 142270177, "ip_address": "51.7.78.188",...}
    #
    #  Relevent property here is `created_user`, so I'm thinking when it's true
    #  we take out the member ID from the `akid` and then update the relevent member
    #  on champaign, by executing the update action (currently missing) in `Api::MembersController`


    unless response.success?
      raise APIError.new('Error while creating AK action', response)
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
