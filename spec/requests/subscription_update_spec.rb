require 'rails_helper'

describe "REST" do
  describe 'POST profileupdatepush to update recurring payment' do

    let(:params) do
      { type: 'recurring_payment_update', params: { recurring_id: 'g85dkg', amount: 10 } }
    end

    it 'updates the subscription with a success code from the client' do
      VCR.use_cassette('subscription update success') do
        post '/message', params: params
        expect(response.status).to eq(200)
        expect(response.body).to eq('null')
      end
    end

  end
end