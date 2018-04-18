require 'rails_helper'

describe GetConstituency do
  context "postcode found" do

    before do
      @client = Aws::DynamoDB::Client.new(stub_responses: {
          get_item: {
            item: { 'constituency' => 'Stafford'}
          }
        }
      )
    end

    it "returns constituency" do
      expect(
        GetConstituency.for('ST19 5RN', @client)
      ).to eq('Stafford')
    end
  end

  context "postcode not found" do
    before do
      @client = Aws::DynamoDB::Client.new(stub_responses: true)
    end

    it "returns nil" do
      expect(
        GetConstituency.for('FOO', @client)
      ).to be nil
    end
  end
end
