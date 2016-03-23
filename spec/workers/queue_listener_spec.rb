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
      end

      let(:params) do
        {
          type: 'update_pages',
          petition_uri:  "/rest/v1/petitionpage/1234/",
          donation_uri:  "/rest/v1/donationpage/5678/",
          params: {
            tags: ["/rest/v1/tag/5678/"]
          }
        }
      end

      it 'calls update_donation_page on client' do
        expected_params = {
          tags: ["/rest/v1/tag/5678/"],
          id: '5678'
        }

        expect(client).to receive(:update_donation_page).with(expected_params)
        subject.perform(nil, params)
      end

      it 'calls update_petition_page on client' do
        expected_params = {
          tags: ["/rest/v1/tag/5678/"],
          id: '1234'
        }

        expect(client).to receive(:update_petition_page).with(expected_params)
        subject.perform(nil, params)
      end

      context 'without resource URI' do
        before do
          params[:petition_uri] = nil
        end

        let(:expected_params) do
          {
            tags: ["/rest/v1/tag/5678/"],
            id: nil
          }
        end

        it "raises argument error" do
          expect(client).not_to receive(:update_petition_page).with(expected_params)

          expect{
            subject.perform(nil, params)
           }.to raise_error(ArgumentError, /Missing resource URI/)
        end
      end
    end
  end
end

