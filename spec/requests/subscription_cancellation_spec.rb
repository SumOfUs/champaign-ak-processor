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
        post '/message', params
        expect(response.status).to eq(200)
        expect(response.body).to eq('null')
      end
    end

    it 'raises an error in case of missing parameters' do
      VCR.use_cassette('subscription cancellation failure') do
        #TODO: I can't get an error assertion to work here. Errors get caught in request specs. Not sure where to put this spec, so if you have good ideas, do tell.
        expect { post '/message', bad_params }.to raise_error(QueueListener::Error, "Marking recurring donation cancelled failed. HTTP Response code: 400, body: {\"canceled_by\": [\"The canceled_by parameter is required.\"]}")
        expect(response.status).to be 500
      end
    end
  end
end