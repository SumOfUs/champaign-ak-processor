class DonationCreator
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
    params[:params][:action] ||= {}
    params[:params][:action][:fields] ||= {}
    params[:params][:action][:fields].merge!(
      mailing_id:           extract_mailing_id(params[:params][:akid]),
      referring_mailing_id: extract_mailing_id(params[:params][:referring_akid]),
      referring_user_id:    extract_user_id(params[:params][:referring_akid])
    )

    response = client.create_donation(params[:params])
    if !response.success?
      raise Error.new("Error while creating AK donation action. HTTP Response code: #{response.code}, body: #{response.body}")
    end

    order = params[:params][:order]
    if params[:payment_provider] == 'go_cardless' && order[:trans_id].present?
      update_gocardless_transaction(order[:trans_id], response.parsed_response)
    end

    Broadcast.emit(
      params[:meta].merge(type: 'donation', amount: order[:amount], currency: order[:currency] )
    )
    response
  end

  private

  def update_gocardless_transaction(trans_id, resp)
    begin
      updator = GocardlessTransactionUpdator.new(gocardless_transaction_id: trans_id, actionkit_response: resp)
      updator.update
    rescue => e
      Rails.logger.error "Error occurred updating gocardless transaction #{e.try(:message)}"
    end
  end

  def extract_mailing_id(akid = '')
    (akid.try(:split, '.') || []).first
  end

  def extract_user_id(akid = '')
    (akid.try(:split, '.') || [])[1]
  end
end