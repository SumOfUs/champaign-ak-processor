require 'rails_helper'

describe PageCreator do

  context "when neither resource exists" do

  end


  context "when one resource exists already" do

    # Actual params of a page that was impacted by this bug - needed for creating the VCR cassette
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

    it "doesn't error out before creating the missing resource" do
      page = double(id: 4699, ak_donation_resource_uri: 'asd.com/donation', ak_petition_resource_uri: nil)
      allow(Page).to receive(:find).with(4699).and_return page
      allow(page).to receive(:update!).and_return double(id: 4699,
                                                        ak_donation_resource_uri: 'asd.com/donation',
                                                        ak_petition_resource_uri: 'https://act.sumofus.org/rest/v1/petitionpage/23597/')
      ak_client_params = {
          page_id: 4699,
          name: "aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1-petition",
          title: "Aidez-nous à révéler le cruel secret des poussins de McDonald's (Petition)",
          language: "/rest/v1/language/100/",
          tags: nil,
          url: "https://actions.sumofus.org/a/aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1",
          hosted_with: "/rest/v1/hostingplatform/2/",
          page_type: "petition",
          multilingual_campaign: nil
      }

      VCR.use_cassette('PageCreator donation page already exists', :record => :new_episodes) do
        expect(page).to receive(:update!).with(
                            {ak_petition_resource_uri: 'https://act.sumofus.org/rest/v1/petitionpage/23597/',
                             status: 'success'})
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petition_page)
          .with(ak_client_params)
          .and_call_original
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petitionform)
          .with(hash_including({
                                   page: 'https://act.sumofus.org/rest/v1/petitionpage/23597/',
                                   client_url: 'https://actions.sumofus.org/a/aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1',
                               }))
          .and_call_original
        response = PageCreator.run(params[:params])
        expect(response).to be_success

      end
    end
  end
end
