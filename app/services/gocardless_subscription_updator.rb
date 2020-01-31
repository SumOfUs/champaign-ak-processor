# Update Champaign's Gocardless Subscription record
# using the Gocardless stateless api exposed in Champaign
class GocardlessSubscriptionUpdator
  include ActiveModel::Validations

  attr_accessor :gocardless_id, :actionkit_response
  attr_reader   :formatted_data

  validates :gocardless_id, presence: true
  validates :actionkit_response,  presence: true
  validate  :verify_actionkit_response

  def initialize(options={})
    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def update
    begin
      unless self.valid?
        Rails.logger.error "Error occured: Errors: #{full_error_message}"
        return false
      end

      resp = HTTParty.put(api_end_point,
                  body: formatted_data.to_json,
                  headers: {"Content-Type" => 'application/json',
                            "X-Api-Key" => ENV['CHAMPAIGN_API_KEY']
                            })
      record_updated_in_champaign?(resp.parsed_response)
    rescue => e
      Rails.logger.error "Error occured while posting actionkit data to Champaign. Details: #{e.inspect}"
      false
    end
  end

  def api_end_point
    ENV['CHAMPAIGN_HOST'].to_s + "/api/stateless/go_cardless/subscriptions/#{gocardless_id}"
  end

  def formatted_data
    @formatted_data ||= data_attrs.collect{|attr| {"ak_#{attr}" => send(attr)} }.reduce({}, :merge).to_h
  end

  def order_id
    actionkit_response.dig('order', 'id').to_s
  end

  def data_attrs
    ['order_id']
  end

  def full_error_message
    self.errors.full_messages.to_sentence
  end

  private

  def record_updated_in_champaign?(resp)
    self.errors.add(:base, resp['message']) and return false unless resp['success']
    true
  end

  def verify_actionkit_response
    return unless actionkit_response.present?
    errors.add(:actionkit_response, "is invalid") and return false unless actionkit_response.is_a?(Hash)

    if formatted_data.dig('ak_order_id').empty?
      errors.add(:actionkit_response, "does not have order_id details")
      return false
    end
    true
  end
end