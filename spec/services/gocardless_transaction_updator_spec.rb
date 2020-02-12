require 'rails_helper'

describe GocardlessTransactionUpdator do
  let(:trans_id)   { "PM000000000000" }
  let(:valid_data) {
    {"akid"=>".100000000000000000.abcdef",
    "created_at"=>"2020-01-22T12:25:40.677752",
    "created_user"=>false,
    "fields"=>{
      "account_number_ending"=>"11",
      "bank_name"=>"BARCLAYS BANK PLC",
      "express_donation"=>0,
      "mandate_reference"=>"SUMOFUS-G00000001",
      "mobile"=>"desktop",
      "payment_gateway_status"=>"pending",
      "phone_number"=>""
    },
    "id"=>10000000000000,
    "ip_address"=>"0.0.0.0",
    "is_forwarded"=>false,
    "link"=>nil,
    "mailing"=>nil,
    "opq_id"=>"",
    "order"=>{
      "account"=>"GoCardless GBP",
      "action"=>"/rest/v1/donationaction/10000000000000/",
      "card_num_last_four"=>"DDEB",
      "created_at"=>"2020-01-22T12:25:40.738954",
      "currency"=>"GBP",
      "id"=>100000000000,
      "import_id"=>nil,
      "orderdetails"=>[],
      "orderrecurrings"=>[], "payment_method"=>"cc",
      "resource_uri"=>"/rest/v1/order/100000000000/",
      "reverse"=>"/rest/v1/order/100000000000/reverse/",
      "shipping_address"=>nil,
      "status"=>"completed",
      "total"=>"10.15", "total_converted"=>"13.292665008161128",
      "transactions"=>["/rest/v1/transaction/100000000000/"],
      "updated_at"=>"2020-01-22T12:25:40.745696",
      "user"=>"/rest/v1/user/100000000000000000/",
      "user_detail"=>"/rest/v1/orderuserdetail/10000/"},
      "page"=>"/rest/v1/donationpage/100000000000000/",
      "referring_mailing"=>nil,
      "referring_user"=>nil,
      "resource_uri"=>"/rest/v1/donationaction/999999999999/",
      "source"=>"website",
      "status"=>"complete",
      "subscribed_user"=>false,
      "taf_emails_sent"=>nil,
      "type"=>"Donation",
      "updated_at"=>"2020-01-22T12:25:41.044690",
      "user"=>"/rest/v1/user/100000000000000000/"
  }}

  let(:invalid_data) {
    valid_data.except('order').merge('order': {payment_gateway_status: 'pending'})
  }
  let(:valid_resp) {
    { body: '{"success": true, "message": "record updated" }',
      status: 200, headers: { 'Content-Type' => 'application/json' } }
  }

  let(:invalid_resp) {
    { body: '{"success": false, "message": "record not found" }',
      status: 200, headers: { 'Content-Type' => 'application/json' } }
  }

  describe "Validations" do
    context "empty attributes" do
      subject { GocardlessTransactionUpdator.new(gocardless_transaction_id: '', actionkit_response: '') }

      it "should validate presence of attributes" do
        expect(subject.update).to be false

        expect(subject.errors[:gocardless_transaction_id].first).to match "can't be blank"
        expect(subject.errors[:actionkit_response].first).to match "can't be blank"
      end
    end

    context "missing attributes" do
      subject { GocardlessTransactionUpdator.new(gocardless_transaction_id: trans_id, actionkit_response: invalid_data) }

      it "should validate presence of order and transaction details" do
        expect(subject.update).to be false

        expect(subject.errors).not_to include(:gocardless_transaction_id)

        msg = "does not have order_id or transaction_id details"
        expect(subject.errors[:actionkit_response].first).to match msg
      end
    end
  end

  describe ".update" do
    context "successful update" do
      subject { GocardlessTransactionUpdator.new(gocardless_transaction_id: trans_id, actionkit_response: valid_data) }

      it "should update the transaction record" do
        VCR.use_cassette('Tranactionupdator successful_update') do
          stub_request(:put, "https://action-staging.sumofus.org/api/stateless/go_cardless/transactions/PM000000000000").
          with(
           body: subject.formatted_data.to_json,
           headers: {
       	  'Content-Type'=>'application/json',
       	  'X-Api-Key'=>'supersecretapikey'
          }).to_return(valid_resp)

          expect(subject.update).to be true
          expect(subject.errors).to be_empty
        end
      end
    end

    context "unsuccessful update" do
      subject { GocardlessTransactionUpdator.new(gocardless_transaction_id: trans_id, actionkit_response: valid_data) }

      it "should update the transaction record" do
        VCR.use_cassette('gocardless_tranaction_updator_unsuccessful_update') do
          stub_request(:put, "https://action-staging.sumofus.org/api/stateless/go_cardless/transactions/PM000000000000").
          with(
           body: subject.formatted_data.to_json,
           headers: {
       	  'Content-Type'=>'application/json',
       	  'X-Api-Key'=>'supersecretapikey'
          }).to_return(invalid_resp)

          expect(subject.update).to be false
          expect(subject.errors[:base].first).to match 'record not found'
        end
      end
    end
  end
end
