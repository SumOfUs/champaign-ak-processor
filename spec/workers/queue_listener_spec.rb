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
  end
end

