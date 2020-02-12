require 'rails_helper'

describe QueueListener do
  let(:client) { double }

  before do
    allow(ActionKitConnector::Client).to receive(:new) { client }
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

    describe 'creating a US action with an invalid zip code' do
      let(:internal_params) do
        {
            page:         "foo-bar",
            name:         "Pablo José Francisco de María",
            postal:       "abc123",
            address1:     "Mill st 123",
            address2:     "apt 1043",
            city:         "London",
            country:      "United States",
            email:        "test@example.com",
            source:       'FB',
            akid:         '3.4234.fsdf'
        }
      end

      let(:action) { Action.create(form_data: {}) }
      let(:params) { { type: 'action', params: internal_params, meta: { action_id: action.id, member_id: 1} } }
      let(:res) { double(success?: true, parsed_response: {'errors' => 'PARSED_ERRORS' }, body: "{}") }

      before do
        allow(client).to receive(:create_action){ res }
        allow(res).to receive(:[]).with('resource_uri'){'resource_uri'}
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("BYPASS_ZIP_VALIDATION"){ 'true' }
      end

      context 'Environment variables are correctly set' do
        it 'falls back to a default zip code' do
          allow(ENV).to receive(:[]).with("DEFAULT_US_ZIP"){ '20001' }
          expect{ subject.perform('action', params) }.not_to raise_error
          expect(client).to have_received(:create_action).with(internal_params)
        end
      end

      context 'With default us zip value missing' do
        it 'complains about missing configuration' do
          expect{ subject.perform('action', params) }.to raise_error /Your default US zip code has not been set/
        end
      end

    end
  end
end

