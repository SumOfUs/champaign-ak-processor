# frozen_string_literal: true

require 'rails_helper'

describe 'REST' do
  let(:language) { Language.create(code: 'en', name: 'English') }
  let(:page) { Page.create(title: 'Foo', slug: 'foo-bar', language: language) }

  before do
    allow_any_instance_of(ActionKitConnector::Client).to(
      receive(:create_petitionform).and_return(double(success?: true))
    )

    allow_any_instance_of(ActionKitConnector::Client).to(
      receive(:create_donationform).and_return(double(success?: true))
    )
  end

  describe 'MessageHandler' do
    describe 'update_pages' do
      context 'page does not exist on ActionKit' do
        let(:params) do
          {
            type: 'update_pages',
            petition_uri: '',
            donation_uri: '',
            title: 'house of cards',
            params: {
              tags: ['/rest/v1/tag/5678/']
            }
          }
        end

        subject do
          VCR.use_cassette('page_update_404') do
            post '/message', params: params.to_json, headers: {
              'CONTENT_TYPE' => 'application/json'
            }
          end
        end

        it 'responds 500 Internal Server Error' do
          subject
          expect(response.code).to eq('500')
        end
      end

      context 'successfully updates' do
        before do
          allow_any_instance_of(ActionKitConnector::Client).to(
            receive(:update_donation_page)
          )

          allow_any_instance_of(ActionKitConnector::Client).to(
            receive(:update_petition_page)
          )
        end

        let(:params) do
          {
            type: 'update_pages',
            petition_uri: '/rest/v1/petitionpage/12853/',
            donation_uri: '/rest/v1/donationpage/12854/',
            params: {
              title: 'house of cards',
              campaign_id: 123
            }
          }
        end

        subject do
          VCR.use_cassette('page_update_200') do
            post '/message', params: params.to_json, headers: {
              'CONTENT_TYPE' => 'application/json'
            }
          end
        end

        context 'title' do
          it 'adds title suffix to petition page' do
            expect_any_instance_of(ActionKitConnector::Client).to(
              receive(:update_petition_page).with(hash_including(title: 'house of cards (Petition)'))
            )
            expect_any_instance_of(ActionKitConnector::Client).to(
              receive(:update_donation_page).with(hash_including(title: 'house of cards (Donation)'))
            )

            subject
          end
        end

        context 'multilingual_campaign' do
          before do
            CampaignRepository.set(123, 'http://dummy-campaign')
          end

          it 'sends the multilingual campaign uri matching the passed campaign_id' do
            expect_any_instance_of(ActionKitConnector::Client).to(
              receive(:update_petition_page).with(hash_including(multilingual_campaign: 'http://dummy-campaign'))
            )
            expect_any_instance_of(ActionKitConnector::Client).to(
              receive(:update_donation_page).with(hash_including(multilingual_campaign: 'http://dummy-campaign'))
            )

            subject
          end
        end
      end
    end
  end

  describe 'creating page resources for a new page' do
    before { CampaignRepository.set(345, 'https://act.sumofus.org/rest/v1/multilingualcampaign/139/') }

    let(:params) do
      { type: 'create',
        params: {
          page_id: page.id,
          name: 'this-page-does-not-exist-13172406',
          title: 'Foo Bar',
          url: 'http://example.com',
          language: '/rest/v1/language/100/',
          campaign_id: 345
        } }
    end

    subject { page.reload }

    describe 'form documents' do
      it 'creates a petitionform' do
        expect_any_instance_of(ActionKitConnector::Client).to(
          receive(:create_petitionform)
          .with(hash_including(
                  client_hosted: true,
                  client_url: 'http://example.com',
                  ask_text: 'Dummy ask',
                  thank_you_text: 'Dummy thank you',
                  statement_text: 'Dummy statement',
                  page: 'https://act.sumofus.org/rest/v1/petitionpage/16944/'
                ))
        )

        VCR.use_cassette('page_create') do
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
        end
      end

      it 'creates a donationform' do
        expect_any_instance_of(ActionKitConnector::Client).to(
          receive(:create_donationform)
          .with(hash_including(
                  client_hosted: true,
                  client_url: 'http://example.com',
                  ask_text: 'Dummy ask',
                  thank_you_text: 'Dummy thank you',
                  statement_text: 'Dummy statement',
                  page: 'https://act.sumofus.org/rest/v1/donationpage/16943/'
                ))
        )

        VCR.use_cassette('page_create') do
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
        end
      end
    end

    context 'payload' do
      it 'has correct properties' do
        expect_any_instance_of(ActionKitConnector::Client).to(
          receive(:create_donation_page)
          .with(
            page_id: page.id,
            name: 'this-page-does-not-exist-13172406-donation',
            title: 'Foo Bar (Donation)',
            language: '/rest/v1/language/100/',
            page_type: 'donation',
            hpc_rule: '/rest/v1/donationhpcrule/22/',
            multilingual_campaign: 'https://act.sumofus.org/rest/v1/multilingualcampaign/139/',
            url: 'http://example.com'
          )
          .and_call_original
        )

        expect_any_instance_of(ActionKitConnector::Client).to(
          receive(:create_petition_page)
          .with(
            page_id: page.id,
            name: 'this-page-does-not-exist-13172406-petition',
            title: 'Foo Bar (Petition)',
            language: '/rest/v1/language/100/',
            page_type: 'petition',
            multilingual_campaign: 'https://act.sumofus.org/rest/v1/multilingualcampaign/139/',
            url: 'http://example.com'
          ).and_call_original
        )

        VCR.use_cassette('page_create') do
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
        end
      end
    end

    context 'with successful request' do
      before do
        VCR.use_cassette('page_create') do
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
        end
      end

      describe 'recording AK resource to page' do
        it 'records petition resource URI' do
          expect(subject.ak_petition_resource_uri).to match(%r{https://act.sumofus.org/rest/v1/petitionpage/\d+/})
        end

        it 'records donation resource URI' do
          expect(subject.ak_donation_resource_uri).to match(%r{https://act.sumofus.org/rest/v1/donationpage/\d+/})
        end

        it 'records status' do
          expect(subject.status).to eq('success')
        end
      end
    end

    context 'with an unsuccessful request (invalid slug)' do
      before do
        params[:slug] = '}not-valid-chars{'

        VCR.use_cassette('page_create_invalid') do
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
        end
      end

      it 'records the failed AK status on the page' do
        expect(subject.status).to eq('failed')
      end
    end

    context 'when it fails to create resources or update the AK resource URIs on the page' do
      let!(:language) { Language.create(code: 'en', name: 'English') }

      let!(:new_page) do
        Page.create(
          id: 12_345_643,
          title: 'Vote for this super random horsey pony!',
          slug: 'super-random-horsey-pony',
          ak_donation_resource_uri: nil,
          ak_petition_resource_uri: nil,
          language: language
        )
      end

      let(:params) do
        {
          type: 'create',
          params: {
            page_id: 12_345_643,
            name: 'super-random-horsey-pony',
            title: 'Vote for this super random horsey pony!',
            language: '/rest/v1/language/100/',
            tags: nil,
            url: 'https://actions.sumofus.org/a/super-random-horsey-pony',
            hosted_with: '/rest/v1/hostingplatform/2/',
            campaign_id: nil
          }
        }
      end

      it 'sends back an error code so the Elastic Beanstalk worker will trigger retry logic' do
        VCR.use_cassette('PageCreator new pages', record: :new_episodes) do
          allow_any_instance_of(ActionKitConnector::Client).to receive(:create_petition_page).and_return(
            double(success?: false,
                   parsed_response: "The request couldn't be satisfied.",
                   code: 500,
                   body: 'Iamafailedresponse')
          )
          post '/message', params: params.to_json, headers: {
            'CONTENT_TYPE' => 'application/json'
          }
          new_page.reload
          expect(new_page.ak_donation_resource_uri).to eq 'https://act.sumofus.org/rest/v1/donationpage/23604/'
          expect(new_page.ak_petition_resource_uri).to eq nil
          expect(new_page.messages).to eq "Failed creating AK petition resource: The request couldn't be satisfied."
          expect(new_page.status).to eq 'failed'
          expect(response.code).to eq('500')
        end
      end
    end
  end
end
