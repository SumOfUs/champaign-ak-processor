require "rails_helper"

describe CampaignCreator do
  context "given valid params" do
    it "returns a response object with 201 Created status" do
      VCR.use_cassette "create_multilingual_campaign_200" do
        response = CampaignCreator.run(name: "Test Campaign 4")
        expect(response.code).to eq 201
      end
    end
  end

  context "given invalid params" do
    it "raises a CampaignCreator::Error" do
      VCR.use_cassette "create_multilingual_campaign_400" do
        expect {
          CampaignCreator.run(name: "Test Campaign 4")
        }.to raise_error(CampaignCreator::Error)
      end
    end
  end
end
