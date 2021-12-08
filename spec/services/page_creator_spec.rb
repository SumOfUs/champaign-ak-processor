require 'rails_helper'
require 'securerandom'

describe PageCreator do
  before { allow(SecureRandom).to(receive(:hex)).and_return("xyz") }
  let!(:language) { Language.create(code: 'en', name: 'English') }

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

    let!(:new_page) { Page.create(
      id: 12345643,
      title: 'Vote for this super random horsey pony!',
      slug: 'super-random-horsey-pony',
      ak_donation_resource_uri: nil,
      ak_petition_resource_uri: nil,
      language: language
    )}

    petition_page_params = {
      name: 'super-random-horsey-pony-xyz-petition',
      title: 'Vote for this super random horsey pony! (Petition)',
      page_type: 'petition',
      multilingual_campaign: nil
    }
    donation_page_params = {
      name: 'super-random-horsey-pony-xyz-donation',
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
    follow_up_hash = {
      page: 'https://act.sumofus.org/rest/v1/donationpage/23604/'
    }

    it "creates petition and donation page as well as petition and donation forms and a follow up resource" do
      VCR.use_cassette('PageCreator new pages') do
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
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_page_follow_up)
                                                                  .with(hash_including(follow_up_hash))
                                                                  .and_call_original
        PageCreator.run(params[:params])
        new_page.reload
        expect(new_page.ak_petition_resource_uri).to eq 'https://act.sumofus.org/rest/v1/petitionpage/23605/'
        expect(new_page.ak_donation_resource_uri).to eq 'https://act.sumofus.org/rest/v1/donationpage/23604/'
      end

    end
  end

  context "when the donation page exists but the petition page doesn't" do

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

    let!(:page) { Page.create(
      id: 4699,
      title: "Aidez-nous à révéler le cruel secret des poussins de McDonald's",
      slug: 'aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1',
      ak_donation_resource_uri: 'https://act.sumofus.org/rest/v1/donationpage/23556/',
      ak_petition_resource_uri: nil,
      language: language,
      messages: "Failed creating AK petition resource: The request couldn't be satisfied.",
      status: 'failed'
    )}


    it "doesn't error out before creating the missing resource" do
      ak_client_params = {
        page_id: 4699,
        name: "aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1-xyz-petition",
        title: "Aidez-nous à révéler le cruel secret des poussins de McDonald's (Petition)",
        language: "/rest/v1/language/100/",
        tags: nil,
        url: "https://actions.sumofus.org/a/aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1",
        hosted_with: "/rest/v1/hostingplatform/2/",
        page_type: "petition",
        multilingual_campaign: nil
      }

      VCR.use_cassette('PageCreator donation page already exists') do
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petition_page)
          .with(ak_client_params)
          .and_call_original
        expect_any_instance_of(ActionKitConnector::Client).to receive(:create_petitionform)
          .with(hash_including({
                                   page: 'https://act.sumofus.org/rest/v1/petitionpage/23597/',
                                   client_url: 'https://actions.sumofus.org/a/aidez-nous-a-reveler-le-cruel-secret-des-poussins-de-mcdonald-s-1',
                               }))
          .and_call_original
        PageCreator.run(params[:params])
        page.reload
        expect(page.ak_petition_resource_uri).to eq 'https://act.sumofus.org/rest/v1/petitionpage/23597/'
        expect(page.status).to eq 'success'
        expect(page.messages).to be nil

      end
    end
  end

end
