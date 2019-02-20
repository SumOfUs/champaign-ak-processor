require 'rails_helper'

describe PageCreator do

  context "when neither a donation or petition page exists (not a retry)" do
    let(:params) do
      {
          type: 'create',
          params: {
              page_id: 12345643,
              name: "super-random-horsey-pony",
              title: "Vote for this super random horsey pony!",
              language: "/rest/v1/language/100/",
              tags: nil,
              url: "https://actions.sumofus.org/a/super-random-horsey-pony",
              hosted_with: "/rest/v1/hostingplatform/2/",
              campaign_id: nil
          }
      }
    end

    it "creates petition and donation page as well as petition and donation forms" do
      page = double(id: 12345643,
                    ak_donation_resource_uri: nil,
                    ak_petition_resource_uri: nil,
                    language: double(code: 'en'))
      allow(Page).to receive(:find).with(12345643).and_return page
      allow(page).to receive(:update!)
      allow(PageFollowUpCreator).to receive(:run).and_return(double(success?: true))
      petition_page_params =
        {
          name: 'super-random-horsey-pony-petition',
          title: 'Vote for this super random horsey pony! (Petition)',
          page_type: 'petition',
          multilingual_campaign: nil
        }
      donation_page_params =
        {
          name: 'super-random-horsey-pony-donation',
          title: 'Vote for this super random horsey pony! (Donation)',
          page_type: 'donation',
          multilingual_campaign: nil,
          hpc_rule: '/rest/v1/donationhpcrule/22/'
        }
      petition_form_hash = {
        page: 'https://act.sumofus.org/rest/v1/petitionpage/23605/',
        client_url: 'https://actions.sumofus.org/a/super-random-horsey-pony',
      }
      donation_form_hash = {
        page: 'https://act.sumofus.org/rest/v1/donationpage/23604/',
        client_url: 'https://actions.sumofus.org/a/super-random-horsey-pony',
      }

      VCR.use_cassette('PageCreator new pages', :record => :new_episodes) do
        expect(page).to receive(:update!).with(
          {ak_petition_resource_uri: 'https://act.sumofus.org/rest/v1/petitionpage/23605/',
           status: 'success'})
        expect(page).to receive(:update!).with(
          {ak_donation_resource_uri: 'https://act.sumofus.org/rest/v1/donationpage/23604/',
           status: 'success'})
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_donation_page)
                                                                  .with(hash_including(donation_page_params))
                                                                  .and_call_original
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_donationform)
                                                                  .with(hash_including(donation_form_hash))
                                                                  .and_call_original
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petition_page)
                                                                  .with(hash_including(petition_page_params))
                                                                  .and_call_original
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petitionform)
                                                                  .with(hash_including(petition_form_hash))
                                                                  .and_call_original
        response = PageCreator.run(params[:params])
        expect(response).to be_success

      end

    end
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

    it "doesn't error out before creating the missing resource and also the follow up page" do
      page = double(id: 4699,
                    ak_donation_resource_uri: 'https://act.sumofus.org/rest/v1/donationpage/23556/',
                    ak_petition_resource_uri: nil,
                    language: double(code: 'en'))
      allow(Page).to receive(:find).with(4699).and_return page
      allow(page).to receive(:update!)
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
