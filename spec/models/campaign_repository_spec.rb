require 'rails_helper'

describe CampaignRepository do
  describe ".get" do
    it "returns nil if key is not present" do
      expect(CampaignRepository.get("some_key")).to be_nil
    end

    it "returns the stored value if present" do
      CampaignRepository.set("key", "http://a_uri")
      expect(CampaignRepository.get("key")).to eq("http://a_uri")
    end
  end
end
