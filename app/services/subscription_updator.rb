class SubscriptionUpdator
    class Error < StandardError; end
    include Ak::Client
  
    def self.run(params)
      new(params).run
    end
  
    def initialize(params)
      @params = params[:params]
      @subscription_id = @params[:recurring_id] || raise(ArgumentError)
      @transaction_id = @params[:trans_id]
      @response_code = @params[:processor_response_code]
      @amount = @params[:amount]&.to_d || 0
    end
  
    def run
      handle_subscription_charge()
    end
  
    private
  
    def handle_subscription_charge()
        return unless subscription
        # Return if a transaction record already exists for this subscription charge. This is to prevent processing
        # the same subscription charge twice.
        return unless Payment::Braintree::Transaction.find_by(transaction_id: @transaction_id).blank?

        update_subscription()
        create_subscription_charge()
        true
      end

      def subscription
        @subscription ||= Payment::Braintree::Subscription.find_by(subscription_id: @subscription_id)
      end

      def update_subscription()
        if @amount > 0 && subscription.amount != @amount
          subscription.update!(amount: @amount)
          update_recurring_payment()
        end
      end

      def create_subscription_charge()
        record = Payment::Braintree::Transaction.create!(
          transaction_id: @transaction_id,
          subscription: subscription,
          page_id: subscription.action.page_id,
          customer: customer,
          status: 'success',
          amount: @amount,
          processor_response_code: @response_code,
          currency: subscription.currency
        )
      end

      def update_recurring_payment()
        res = client.update_recurring_payment({
            recurring_id: @subscription_id,
            amount: @amount.to_s
          }
        )
        unless res.success?
          raise Error.new("Updating recurring payment failed with #{res.parsed_response['errors']}")
        end
      end

      def original_action
        @action ||= subscription.try(:action)
      end

      def customer
        Payment::Braintree::Customer.find_by(member_id: original_action.member_id)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.error("No Braintree customer found for member with id #{original_action.member_id}!")
          log_failure
      end
  end
