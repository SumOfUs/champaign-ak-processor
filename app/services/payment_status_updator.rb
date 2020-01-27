class PaymentStatusUpdator
  include Ak::Client
  class Error < StandardError; end

  attr_reader :params

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params.clone.to_h.with_indifferent_access
  end

  def run
    if id.blank? || data.blank?
      raise Error.new("Error while updating AK donationaction payment status. Either id or data is blank")
    end

    response = client.update_donation_action(id, data)
    if !response.success?
      raise Error.new("Error while updating AK donationaction payment status. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  private

  def data
    {fields: {payment_gateway_status: @params.dig('params','payment_gateway_status')}}
  end

  def id
    @params.dig("params", "ak_donation_action_id")
  end
end
