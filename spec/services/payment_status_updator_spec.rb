require 'rails_helper'

describe PaymentStatusUpdator do

  let(:data) {
    {params: {ak_order_id: '213123', ak_donation_action_id: '34234234',
    ak_transaction_id: '234234', payment_gateway_status: 'paid_out'}}
  }

  let(:invalid_data) {
    {params: {ak_order_id: '213123', ak_donation_action_id: '34234231',
    ak_transaction_id: '234234', payment_gateway_status: 'paid_out'}}
  }

  let(:successful_response) { double('success?' => true) }

  before do
    allow(Ak::Client.client).to receive(:update_donation_action).
                                and_return(successful_response)
  end

  it 'updates the ak donation action payment_gateway_status' do
    VCR.use_cassette('PaymentUpdator success update') do
      resp = PaymentStatusUpdator.run(data)
      expect(resp).to be_success
    end
  end
end