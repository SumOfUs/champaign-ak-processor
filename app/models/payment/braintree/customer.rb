class Payment::Braintree::Customer < ApplicationRecord
    belongs_to :member
    has_many   :payment_methods,  class_name: 'Payment::Braintree::PaymentMethod',
                                   foreign_key: 'customer_id'
    has_many   :subscriptions,    class_name: 'Payment::Braintree::Subscription',
                                  foreign_key: 'customer_id',
                                  primary_key: 'customer_id'
    has_many   :transactions,     class_name: 'Payment::Braintree::Transaction',
                                  foreign_key: 'customer_id',
                                  primary_key: 'customer_id'
end
  