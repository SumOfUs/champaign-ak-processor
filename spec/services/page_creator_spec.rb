require 'rails_helper'

describe PageCreator do
  context "when one resource exists already" do

    # Actual params of a page that was impacted by this bug.
    let(:params) do
      {
          type: 'create',
          params: {
              page_id: 4699,
              name: "aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1",
              title: "Aidez-nous à révéler le cruel secret des poussins de McDonald's",
              language: "/rest/v1/language/100/",
              tags: nil,
              url: "https://actions.sumofus.org/a/aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1",
              hosted_with: "/rest/v1/hostingplatform/2/",
              campaign_id: nil
          }
      }
    end


    xit "doesn't error out before creating the missing resource" do
      page = double(id: 4699)
      allow(Page).to receive(:find).with(4699).and_return page

      VCR.use_cassette('PageCreator donation page already exists') do
        # expect_any_instance_of(ActionKitConnector::Client).to receive(:create_action)
        #                                                           .with(hash_including(params[:params]))
        #                                                           .and_call_original
        response = PageCreator.run(params[:params])
        expect(response).to be_success

      end
    end
  end
end
