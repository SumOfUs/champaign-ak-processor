require 'rails_helper'

describe "REST" do

  describe 'PUT /user to update user' do
    let(:body) {
      JSON.parse(response.body)
    }
    describe 'ActionKit' do
      let(:params) do {
        type: 'update_member',
        params: {
          akid: '8244194',
          email: "weriopweirpwgklwrkpowiro@example.com",
          first_name: "Guybrush",
          last_name: "Threepwood",
          country: "United Kingdom",
          postal: "12345",
          address1: "Jam Factory 123",
          address2: "Random address"
        }
      }
      end
      let(:bad_params) do {
        type: 'update_member',
        params: {
          akid: '8244194',
          email: "test@example.com",
          first_name: "Guybrush",
          last_name: "Threepwood",
          country: "United Kingdom",
          postal: "12345",
          address1: "Jam Factory 123",
          address2: "Random address"
        }
      }
      end
      it 'updates the user on ActionKit' do
        VCR.use_cassette("member_update_success") do
          expect(Rails.logger).to_not receive(:error)
          post "/message", params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
          expect(response.status).to eq(200)
        end
      end
      it 'returns errors if the update was unsuccessful but sets status as 200 so the message does not get reprocessed' do
        VCR.use_cassette("member_update_failure") do
          post "/message", params: bad_params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
          expect(response.status).to eq(500)
        end
      end
    end
  end
end
