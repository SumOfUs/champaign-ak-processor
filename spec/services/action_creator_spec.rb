require 'rails_helper'

describe ActionCreator do
  context "given referring_akid is present" do
    around(:example) do |example|
      VCR.use_cassette('ActionCreator with referring_akid 200') do
        example.run
      end
    end

    let(:params) do
      {
        params: {
          :email => "test@sou.com",
          :page => 'petition-test-rodri-petition',
          :referring_akid => '35578.11727499.ygNy8N'
        },
        meta: {
          :member_id => '1'
        }
      }
    end

    it "creates the action on AK" do
      expect_any_instance_of(ActionKitConnector::Client).to receive(:create_action)
        .with(hash_including(params[:params]))
        .and_call_original
      response = ActionCreator.run(params)
      expect(response).to be_success
    end

    it "updates the action on AK after creating it nullifying the mailing_id" do
      expect_any_instance_of(ActionKitConnector::Client).to receive(:update_petition_action)
        .with(instance_of(String), mailing: nil)
        .and_call_original
      response = ActionCreator.run(params)
      expect(response).to be_success
    end

    it "updates the AKID on the member on Champaign if it is a new member" do
      expect(HTTParty).to receive(:patch).with(
          "https://action-staging.sumofus.org/api/members/1",
          {:body=>{:akid=>"14220077"},
           :headers=>{"X-Api-Key"=>"supersecretapikey"}}
      ).and_return({ member: { email: params[:email]} })
      ActionCreator.run(params)
    end
  end
end
