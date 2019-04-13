# frozen_string_literal: true

require 'rails_helper'

describe 'Campaigns', type: :request do
  describe '#create' do
    context 'given valid params' do
      it 'responds 200 OK' do
        VCR.use_cassette 'create_multilingual_campaign_200' do
          post '/message', params: {
            type: 'create_campaign',
            name: 'Test Campaign 4',
            campaign_id: 123
          }
        end
        expect(response.code).to eq '200'
      end
    end

    context 'given invalid params' do
      it 'responds 500 Internal Server Error' do
        VCR.use_cassette 'create_multilingual_campaign_400' do
          post '/message', params: { type: 'create_campaign', name: '' }
          expect(response.code).to eq '500'
        end
      end
    end
  end

  describe '#update' do
    context 'given valid params' do
      before do
        CampaignRepository.set(1234, 'https://act.sumofus.org/rest/v1/multilingualcampaign/120/')
      end

      around(:each) do |example|
        VCR.use_cassette 'update_multilingual_campaign_204' do
          example.run
        end
      end

      it 'responds 200 OK' do
        post '/message', params: {
          type: 'update_campaign', name: 'AKProcessor test: Updated campaign', campaign_id: 1234
        }
        expect(response.code).to eq '200'

        response = client.get_multilingual_campaign(120)
        expect(response.code).to eq 200
        expect(response.parsed_response['name']).to eq 'AKProcessor test: Updated campaign'
      end
    end

    context 'given invalid params' do
      before do
        CampaignRepository.set(1234, 'https://act.sumofus.org/rest/v1/multilingualcampaign/120/')
      end

      it 'responds 500 Internal Server Error' do
        VCR.use_cassette 'update_multilingual_campaign_400' do
          post '/message', params: {
            type: 'update_campaign',
            name: '', # blank name
            campaign_id: 1234
          } 
        end
        expect(response.code).to eq '500'
      end
    end
  end
end
