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
      page:         "rod-test-survey-4-petition",
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
      VCR.use_cassette("new_survey_response-create_action") do
        post '/message', params
      end
    end

    it 'responds successfully' do
      expect(response).to be_success
    end

    it 'stores resource ID in champaign action' do
      expect(action.reload.form_data['ak_resource_id']).to match(%r{rest\/v1\/petitionaction\/})
    end

    it 'stores the new action data in the ActionsRepository' do
      ak_action = ActionRepository.get(action.id)
      expect(ak_action[:page_ak_id]).to match(%r{rest\/v1\/petitionpage\/})
      expect(ak_action[:ak_id]).to be_present
      expect(ak_action[:member_email]).to eql "omar@sumofus.org"
    end
  end

  context "Given the action already exists" do
    let(:update_params) do
      params.clone.tap do |p|
        p[:params][:fields][:age] = '123'
      end
    end

    before do
      # Create action
      VCR.use_cassette("new_survey_response-create_action") do
        post '/message', params
      end
      expect(response.success?).to be_truthy

      @ak_action = ActionRepository.get(action.id)
    end

    it "updates action kit" do
      ak_expected_params = update_params[:params].clone.tap do |p|
        # It overrides `page` with the ak_page_id
        p[:page] = @ak_action[:page_ak_id]
        # It moves every action_* param to a hash inside the `fields` key
        # adding the `survey_` prefix
        p[:fields] = {
          'survey_age' => p[:action_age],
          'survey_foo' => p[:action_foo],
          'survey_bar' => p[:action_bar]
        }
        p.delete('action_age')
        p.delete('action_foo')
        p.delete('action_bar')
      end

      expect(Ak::Client.client).to receive(:update_petition_action).
        with(@ak_action[:ak_id], ak_expected_params).
        and_call_original

      VCR.use_cassette("new_survey_response-update_action") do
        post '/message', update_params
      end
    end

    it "responds successfully" do
      VCR.use_cassette("new_survey_response-update_action") do
        post '/message', update_params
      end

      expect(response).to be_success
    end
  end

  context "Given the action already exists but the a new email is submited" do
    before do
      # Create action
      VCR.use_cassette("new_survey_response-create_action") do
        post '/message', params
      end
      expect(response.success?).to be_truthy

      @ak_action = ActionRepository.get(action.id)
      params[:params][:email] = 'processor1@test.com'
    end

    it "deletes the existing action" do
      expect(Ak::Client.client).to receive(:delete_action).
        with(@ak_action[:ak_id]).
        and_call_original

      VCR.use_cassette("new_survey_response-delete_and_create_action") do
        post '/message', params
      end
    end

    it "creates a new action" do
      expect_any_instance_of(ActionKitConnector::Client).to receive(:create_action).
        and_call_original

      VCR.use_cassette("new_survey_response-delete_and_create_action") do
        post '/message', params
      end
    end

    it "updates the ActionRepository" do
      VCR.use_cassette("new_survey_response-delete_and_create_action") do
        post '/message', params
      end

      updated_action = ActionRepository.get(action.id)
      expect(@ak_action).not_to eql(updated_action)
      expect(updated_action[:ak_id]).to be_present
    end
  end
end
