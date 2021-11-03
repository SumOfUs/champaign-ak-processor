class Payment::Braintree::Transaction < ApplicationRecord
    belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
end
  