require 'rails_helper'

describe QueueListener do
  let(:client) { double }

  before do
    allow(ActionKitConnector::Client).to receive(:new){ client }
  end

  subject { QueueListener.new }

  describe "#perform" do
    describe 'update_pages' do
      before do
        allow(client).to receive(:update_donation_page)
        allow(client).to receive(:update_petition_page)
        CampaignRepository.set(234, "http://dummy-campaign")
      end

      let(:params) do
        {
          type: 'update_pages',
          petition_uri:  "/rest/v1/petitionpage/1234/",
          donation_uri:  "/rest/v1/donationpage/5678/",
          params: {
            tags: ["/rest/v1/tag/5678/"],
            campaign_id: 234
          }
        }
      end

      it 'calls update_donation_page on client' do
        expected_params = {
          tags: ["/rest/v1/tag/5678/"],
          id: '5678',
          multilingual_campaign: "http://dummy-campaign"
        }

        expect(client).to receive(:update_donation_page).with(expected_params)
        subject.perform(nil, params)
      end

      it 'calls update_petition_page on client' do
        expected_params = {
          tags: ["/rest/v1/tag/5678/"],
          id: '1234',
          multilingual_campaign: "http://dummy-campaign"
        }

        expect(client).to receive(:update_petition_page).with(expected_params)
        subject.perform(nil, params)
      end

      context 'missing resource URI' do
        context 'for just petition' do
          before :each do
            params[:petition_uri] = nil
            subject.perform(nil, params)
          end

          it 'does not call update_petition_page on client' do
            expect(client).not_to have_received(:update_petition_page)
          end

          it 'calls update_donation_page on client' do
            expect(client).to have_received(:update_donation_page)
          end
        end

        context 'for just donation' do
          before :each do
            params[:donation_uri] = nil
            subject.perform(nil, params)
          end

          it 'calls update_petition_page on client' do
            expect(client).to have_received(:update_petition_page)
          end

          it 'does not call update_donation_page on client' do
            expect(client).not_to have_received(:update_donation_page)
          end
        end

        context 'for both' do
          before do
            params[:donation_uri] = nil
            params[:petition_uri] = nil
          end

          it 'does not call update_petition_page or update_donation_page on client' do
            expect{ subject.perform(nil, params) }.to raise_error(ArgumentError)
          end
        end
      end
    end

    describe 'subscribe member' do
      let(:internal_params) do
        {
          email: "guybrush_threepwood@example.com",
          name: "Guybrush Threepwood",
          country: "United Kingdom",
          postal: "12345"
        }
      end
      let(:params) { { type: 'subscribe_member', params: internal_params } }
      let(:unset_msg) { "Your ActionKit page for subscriptions from the home page has not been set for locales '' or 'EN'" }
      let(:api_fail_msg) { "Member subscription failed with PARSED_ERRORS!" }
      let(:res) { double(success?: true, parsed_response: {'errors' => 'PARSED_ERRORS' }) }

      before :each do
        allow(client).to receive(:create_action){ res }
      end

      it 'raises an error when there is no locale or AK_SUBSCRIPTION_PAGE_EN' do
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_EN"){ nil }
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_"){ nil }
        expect{ subject.perform('subscribe_member', params) }.to raise_error(unset_msg)
      end

      it "uses the English subscription page if no locale given" do
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_EN"){ 'registration' }
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_"){ nil }
        expect{ subject.perform('subscribe_member', params) }.not_to raise_error
        expect(client).to have_received(:create_action).with(internal_params.merge(page: 'registration'))
      end

      it "uses the English subscription page if current locale doesn't have one" do
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_EN"){ "registration" }
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_DE"){ nil }
        internal_params[:locale] = 'DE'
        expect{ subject.perform('subscribe_member', params) }.not_to raise_error
        expect(client).to have_received(:create_action).with(internal_params.merge(page: 'registration'))
      end

      it "uses the right subscription page if current locale has one" do
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_DE"){ "registration_german" }
        internal_params[:locale] = 'de'
        expect{ subject.perform('subscribe_member', params) }.not_to raise_error
        expect(client).to have_received(:create_action).with(internal_params.merge(page: 'registration_german'))
      end

      it 'raises an error when the API call is not successful' do
        allow(ENV).to receive(:[]).with("AK_SUBSCRIPTION_PAGE_EN"){ 'registration' }
        allow(res).to receive(:success?){ false }
        internal_params[:locale] = 'EN'
        expect{ subject.perform('subscribe_member', params) }.to raise_error(api_fail_msg)
      end
    end
  end
end

