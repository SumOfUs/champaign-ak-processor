class Member < ApplicationRecord
    has_one :customer,               class_name: 'Payment::Braintree::Customer'
    has_one :braintree_customer,     class_name: 'Payment::Braintree::Customer'
    has_many :payment_methods, through: :customer
    has_many :actions
end
  