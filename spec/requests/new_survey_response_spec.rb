require 'rails_helper'

describe "New Survey Response" do
  before do
    allow(Broadcast).to receive(:emit)
    allow(ActionsCache).to receive(:append)
  end

  let(:action) { Action.create(form_data: {}) }

  let(:params) do
    {
      type: 'new_survey_response',
      params: data,
      meta: {
        foo: 'bar',
        action_id: action.id
      }
    }
  end

  let(:data) do
    {
      page:         "some-page-slug",
      name:         "Pablo José Francisco de María",
      postal:       "W1",
      address1:     "The Lodge",
      address2:     "High Street",
      city:         "London",
      country:      "United Kingdom",
      action_age:   "101",
      action_foo:   "Foo",
      action_bar:   "Bar",
      ignored:      "ignore me",
      email:        "omar@sumofus.org",
      source:       'FB',
      akid:         '3.4234.fsdf'
    }
  end

  context "Given an action doesn't exist" do

    before do
      VCR.use_cassette("action_existing_page") do
        post '/message', params
      end
    end

    it 'responds successfully' do
      expect(response).to be_success
    end

    it 'stores resource ID in champaign action' do
      expect(action.reload.form_data['ak_resource_id']).to match(/rest\/v1\/petitionaction\//)
    end

    it 'stores the new action data in the ActionsRepository' do
      ak_action = ActionRepository.get(action.id)
      expect(ak_action[:page_ak_id]).to match(/rest\/v1\/petitionpage\//)
      expect(ak_action[:ak_id]).to be_present
    end
  end

  context "Given the action already exists" do
    let(:update_params) do
      params.clone.tap do |p|
        p[:params][:action_question_1] = '123'
      end
    end

    before do
      # Create action
      VCR.use_cassette("action_existing_page") do
        post '/message', params
      end
      expect(response.success?).to be_truthy

      ak_action = ActionRepository.get(action.id)
      @action_ak_id = ActionKitConnector::Util.extract_id_from_resource_uri(ak_action[:ak_id])
      @page_ak_id = ak_action[:page_ak_id]
    end

    it "updates action kit" do
      # It overrides `page` with the ak_page_id
      ak_expected_params = update_params[:params].tap do |p|
        p[:page] = @page_ak_id
      end

      expect(Ak::Client.client).to receive(:update_petition_action).
        with(@action_ak_id, ak_expected_params).
        and_call_original

      VCR.use_cassette("update_petition_action") do
        post '/message', update_params
      end
    end

    it "responds successfully" do
      VCR.use_cassette("update_petition_action") do
        post '/message', update_params
      end

      expect(response).to be_success
    end
  end
end
