module Payment::Braintree
    class << self
      def table_name_prefix
        'payment_braintree_'
      end
    end
  end