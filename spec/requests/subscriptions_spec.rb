require 'rails_helper'

describe "REST" do

  describe 'POST /action with subscription page' do

    let(:body) {
      JSON.parse(response.body)
    }

    describe 'ActionKit' do

      let(:params) do {
        type: 'subscribe_member',
        params: {
          email: "guybrush_threepwood@example.com",
          name: "Guybrush Threepwood",
          country: "United Kingdom",
          postal: "12345"
        }
      }
      end

      context 'when a subscription page is set' do

        it 'creates a new member' do
          VCR.use_cassette("home_page_subscription_success") do
            post '/message', params
            expect(response.status).to eq(200)
            expect(body['subscribed_user']).to eq(true)
            expect(body['created_user']).to eq(true)
          end
        end
      end

      context 'when a subscription page not set' do
        before do
          allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_NAME"){""}
          allow(ENV).to receive(:[]).with("HOME"){"/root"}
        end
        
        it 'sends an error code if that the default subscription page is not set' do
          post '/message', params
          expect(response.status).to eq(500)
        end
      end
    end
  end
end
