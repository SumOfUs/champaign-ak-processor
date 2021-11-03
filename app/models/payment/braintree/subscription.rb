class Payment::Braintree::Subscription < ApplicationRecord
  has_many :transactions,   class_name: 'Payment::Braintree::Transaction',
                              foreign_key: :subscription_id
end
  