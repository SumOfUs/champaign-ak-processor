class Payment::Braintree::PaymentMethod < ApplicationRecord
  belongs_to :customer, class_name: 'Payment::Braintree::Customer'

  has_many   :subscriptions, class_name: 'Payment::Braintree::Subscription',
                             foreign_key: 'payment_method_id'

  has_many   :transactions, class_name: 'Payment::Braintree::Transaction',
                            foreign_key: 'payment_method_id'
end
  