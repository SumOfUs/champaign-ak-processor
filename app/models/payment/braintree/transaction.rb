class Payment::Braintree::Transaction < ApplicationRecord
  belongs_to :page
  belongs_to :customer,       class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id'
  belongs_to :subscription,   class_name: 'Payment::Braintree::Subscription'
end
  