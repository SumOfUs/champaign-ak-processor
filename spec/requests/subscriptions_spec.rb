require 'rails_helper'

describe "REST" do

  describe 'POST /action with subscription page' do
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
        # VCR.use_cassette("home_page_subscription_success") do
          it 'creates a new member' do
            expect(Ak::Client.client).to receive(:create_action).with(params[:params].merge({ page: 'subscription_page'}))
            post '/message', params
            expect(response.status).to eq(200)
          end
        # end
      end

      context 'when a subscription page not set' do
        ENV['AK_SUBSCRIPTION_PAGE_NAME'] = ''
        it 'notifies that the page is not set' do
          expect(Rails.logger).to receive(:error).with("Your ActionKit page for subscriptions from the home page has not been set!")
          post '/message', params
        end
      end
    end
  end
end
