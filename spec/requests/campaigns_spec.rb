require 'rails_helper'

describe "Campaigns", type: :request do

  describe "#create" do

    context "given valid params" do
      it "responds 200 OK" do
        VCR.use_cassette "create_multilingual_campaign_200" do
          post '/message', type: 'create_campaign', name: 'Test Campaign 4'
        end
        expect(response.code).to eq "200"
      end
    end

    context "given invalid params" do
      it "responds 500 Internal Server Error" do
        VCR.use_cassette "create_multilingual_campaign_400" do
          post '/message', type: 'create_campaign', name: ''
          expect(response.code).to eq "500"
        end
      end
    end

  end

end
