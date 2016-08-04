require 'rails_helper'

describe CampaignUpdater do
  before do
    CampaignRepository.set(1234, "https://act.sumofus.org/rest/v1/multilingualcampaign/120/")
  end

  it "raises an error if a campaign with the passed id doesn't exist" do
    expect { CampaignUpdater.run(campaign_id: 123)}.to raise_error(CampaignRepository::NotFoundError)
  end

  context "given valid params" do
    it "responds 204 No Content" do
      VCR.use_cassette "update_multilingual_campaign_204" do
        response = CampaignUpdater.run name: 'AKProcessor test: Updated campaign', campaign_id: 1234
        expect(response.code).to eq 204
      end
    end
  end

  context "given invalid params" do
    it "raises an CampaignUpdater::Error" do
      VCR.use_cassette "update_multilingual_campaign_400" do
        expect {
          CampaignUpdater.run name: '', campaign_id: 1234 #blank name
        }.to raise_error CampaignUpdater::Error
      end
    end
  end

  context "given another campaign exists with the same name" do
    before do
      # Hardcoding rand so the suffix is always the same and plays well with VCR
      allow_any_instance_of(Object).to receive(:rand).and_return(123)
    end

    it "appends a random number suffix to the name and retries" do
      VCR.use_cassette "update_multilingual_campaign_retry" do
        response = CampaignCreator.run name: "Test Campaign 1236", campaign_id: 12
        expect(response).to be_success

        response = CampaignUpdater.run name: 'Test Campaign 1236', campaign_id: 1234
        expect(response).to be_success
      end
    end
  end
end
