require 'rails_helper'

describe GocardlessSubscriptionTransactionUpdator do
  before do
  end

  let(:params) {
    {ak_order_id: '1986081', recurring_id: 'SB00022FBX3496',
    status: 'failed', success: '0', trans_id: 'PM00108B8NKVAC' }
  }

  context "validations" do
    it "raises error if required params are missing" do
      expect { GocardlessSubscriptionTransactionUpdator.run({})}.to raise_error("Error while updating AK subscription transaction status. ak_order_id / status / trans_id  is missing")
    end
  end

  context "order details" do
    it "should fetch order details" do
      VCR.use_cassette "Gocardless_Subscription_Transaction_successful_update" do
        resp = GocardlessSubscriptionTransactionUpdator.new(params)
        expect(resp.send(:order).dig('id')).to eql 1986081
      end
    end
  end

  context "transaction details" do
    it "should fetch transaction details" do
      VCR.use_cassette "Gocardless_Subscription_Transaction_successful_update" do
        resp = GocardlessSubscriptionTransactionUpdator.new(params)
        resp.send(:transaction).dig('id')
      end
    end
  end

  context "update transaction" do
    it "should update transaction status" do
      VCR.use_cassette "Gocardless_Subscription_Transaction_successful_update" do
        GocardlessSubscriptionTransactionUpdator.run(params)
      end
    end
  end
end
