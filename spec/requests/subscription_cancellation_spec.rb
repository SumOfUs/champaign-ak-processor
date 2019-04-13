require 'rails_helper'

describe "REST" do
  describe 'POST profilecancelpush to cancel subscription' do

    let(:params) do
      { type: 'cancel_subscription', params: { recurring_id: 'g85dkg', canceled_by: 'user' } }
    end

    let(:bad_params) do
      { type: 'cancel_subscription', params: { recurring_id: 'g85dkg'} }
    end

    it 'cancels the subscription with a success code from the client' do
      VCR.use_cassette('subscription cancellation success') do
        post "/message", params: params.to_json, headers: {
          'CONTENT_TYPE' => 'application/json'
        }
        expect(response.status).to eq(200)
        expect(response.body).to eq('null')
      end
    end

    it 'sends back 500 in case of missing parameters' do
      VCR.use_cassette('subscription cancellation failure') do
        post "/message", params: bad_params.to_json, headers: {
          'CONTENT_TYPE' => 'application/json'
        }
        expect(response.status).to be 500
      end
    end
  end
end