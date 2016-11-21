require 'rails_helper'

describe PageFollowUpCreator do

  context 'when creating a follow up page' do
    before do
      allow(Ak::Client.client).to receive(:create_page_follow_up) { double(success?: true) }
    end

    def expect_client_to_receive_param(key, val)
      expect(Ak::Client.client).to receive(:create_page_follow_up).
                                with(hash_including(key => val))
    end

    let(:params) do
      { language_code: 'es',
        page_ak_uri: 'http://dummyurl.com'
      }
    end

    it "sets the correct email wrapper" do
      expect_client_to_receive_param(:email_wrapper, 'https://act.sumofus.org/rest/v1/emailwrapper/25/')
      PageFollowUpCreator.run(params)
    end

    it "sets the page uri passed via params" do
      expect_client_to_receive_param(:page, params[:page_ak_uri])
      PageFollowUpCreator.run(params)
    end

    it "sets the correct email_from_line" do
      expect_client_to_receive_param(:page, params[:page_ak_uri])
      PageFollowUpCreator.run(params)
    end

    it "sets the correct email subject" do
      expect_client_to_receive_param(
        :email_subject,
        I18n.t('page_follow_up.email_subject', locale: 'es', raise: true)
      )
      PageFollowUpCreator.run(params)
    end

    it "sets the correct email body" do
      expect_client_to_receive_param(
        :email_body,
        I18n.t('page_follow_up.email_body', locale: 'es', raise: true)
      )
      PageFollowUpCreator.run(params)
    end

    it "sets send_confirmation to true" do
      expect_client_to_receive_param(:send_confirmation, true)
      PageFollowUpCreator.run(params)
    end
  end
end
