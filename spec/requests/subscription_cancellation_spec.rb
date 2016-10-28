require 'rails_helper'

describe "REST" do
  describe 'POST profilecancelpush to cancel subscription' do

    let(:params) do
      { type: 'cancel_subscription', params: { recurring_id: 'g85dkg', canceled_by: 'user' } }
    end

    let(:bad_params) do
      { type: 'cancel_subscription', params: { recurring_id: 'g85dkg'} }
    end

    it 'Cancels the subscription with a success code from the client' do
      VCR.use_cassette('subscription cancellation success') do
        post '/message', params
        expect(response.status).to eq(200)
        expect(response.body).to eq('null')
      end
    end

    it 'Logs an error in case of missing parameters' do
      VCR.use_cassette('subscription cancellation failure') do
        expect(Rails.logger).to receive(:error).with("Marking recurring donation cancelled failed with"\
        " {\"canceled_by\"=>[\"The canceled_by parameter is required.\"]}!")
        post '/message', bad_params
      end
    end
  end
end