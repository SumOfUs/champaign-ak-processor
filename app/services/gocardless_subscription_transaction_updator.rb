class GocardlessSubscriptionTransactionUpdator
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
  end

  private

  def update_actionkit_transaction
    if ak_order_id.blank? || trans_id.blank? || status.blank?
      raise Error.new("Error while updating AK subscription transaction status. ak_order_id / status / trans_id  is missing")
    end

    if valid_trans_id?
      resp = client.update_transaction(transaction_id, {status: status })
      unless resp.success?
        raise Error.new("Error occurred while updating transaction .....#{resp.parsed_response['errors']}")
      end
      return true
    end
    false
  end

  def ak_order_id
    @params.dig("ak_order_id")
  end

  def trans_id
    @params.dig("trans_id")
  end

  def status
    @params.dig("status")
  end

  def valid_trans_id?
    transaction.dig("trans_id") == trans_id
  end

  def transaction
    @transaction ||= fetch_transaction_details
  end

  def order
    @order ||= fetch_order_details
  end

  def fetch_transaction_details
    return unless transaction_id.present?

    resp = client.get_transaction(transaction_id)
    unless resp.success?
      raise Error.new("Error occurred while fetching transaction .....#{resp.parsed_response['errors']}")
    end
    resp.parsed_response
  end

  def transaction_id
    order.dig("transactions").to_a.last.to_s.split("/").last
  end

  def fetch_order_details
    resp = client.get_order(ak_order_id)
    unless resp.success?
      raise Error.new("Error occurred while fetching order .....#{resp.parsed_response['errors']}")
    end
    resp.parsed_response
  end
end