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
    update_actionkit_transaction
    update_actionkit_donation_action
  end

  private

  def donation_action_data
    {fields: {payment_gateway_status: @params.dig('params','payment_gateway_status')}}
  end

  def donation_action_id
    @params.dig("params", "ak_donation_action_id")
  end

  def transaction_data
    {status: transaction_status}
  end

  def transaction_status
    {'failed': 'failed',
     'cancelled': 'failed',
     'created': 'completed',
     'submitted': 'completed',
     'confirmed': 'completed',
     'paid_out': 'completed',
     'refunded': 'reversed'
    }.with_indifferent_access.dig(payment_gateway_status)
  end

  def payment_gateway_status
    @params.dig('params','payment_gateway_status')
  end

  def transaction_id
    @params.dig("params", "ak_transaction_id")
  end

  def update_actionkit_transaction
    if transaction_id.blank? || transaction_data.blank?
      raise Error.new("Error while updating AK transaction status. Either id or data is blank")
    end

    response = client.update_transaction(transaction_id, transaction_data)
    if !response.success?
      raise Error.new("Error while updating AK transaction status. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end

  def update_actionkit_donation_action
    if donation_action_id.blank? || donation_action_data.blank?
      raise Error.new("Error while updating AK donationaction payment status. Either id or data is blank")
    end

    response = client.update_donation_action(donation_action_id, donation_action_data)
    if !response.success?
      raise Error.new("Error while updating AK donationaction payment status. HTTP Response code: #{response.code}, body: #{response.body}")
    end
    response
  end
end