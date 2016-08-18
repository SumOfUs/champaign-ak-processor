require "rails_helper"

describe CampaignCreator do
  context "given valid params" do
    around(:each) do |example|
      VCR.use_cassette "create_multilingual_campaign_200" do
        example.run
      end
    end

    let(:params) do
      { campaign_id: 123, name: "Test Campaign 4" }
    end

    it "returns a response object with 201 Created status" do
      response = CampaignCreator.run(params)
      expect(response.code).to eq 201
    end

    it "stores the campaign map" do
      CampaignCreator.run(params)
      expect(CampaignRepository.get(123)).not_to be_blank
    end
  end

  context "given invalid params" do
    it "raises a CampaignCreator::Error" do
      VCR.use_cassette "create_multilingual_campaign_400" do
        expect {
          CampaignCreator.run(campaign_id: 123, name: "Test Campaign 4")
        }.to raise_error(CampaignCreator::Error)
      end
    end
  end

  context "given a campaign with the passed name already exists" do
    before do
      # Hardcoding rand so the suffix is always the same and plays well with VCR
      allow_any_instance_of(Object).to receive(:rand).and_return(123)
    end

    it "appends a random number suffix to the name and retries" do
      VCR.use_cassette "create_multilingual_campaign_retry" do
        response = CampaignCreator.run(campaign_id: 123, name: "Test Campaign 6")
        expect(response).to be_success

        response = CampaignCreator.run(campaign_id: 123, name: "Test Campaign 6")
        expect(response).to be_success
      end
    end
  end
end
