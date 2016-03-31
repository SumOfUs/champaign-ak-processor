require 'rails_helper'

describe "REST" do
  let(:page) { Page.create(title: 'Foo', slug: 'foo-bar') }

  before do
    allow_any_instance_of( ActionKitConnector::Client ).to(
      receive(:create_petitionform)
    )

    allow_any_instance_of( ActionKitConnector::Client ).to(
      receive(:create_donationform)
    )
  end

  describe 'MessageHandler' do
    describe 'update_pages' do
      context "page does not exist on ActionKit" do
        let(:params) do
          {
            type: 'update_pages',
            petition_uri:  "",
            donation_uri:  "",
            title: "house of cards",
            params: {
              tags: ["/rest/v1/tag/5678/"]
            }
          }
        end

        subject do
          VCR.use_cassette('page_update_404'){ post("/message", params) }
        end

        it 'fails' do
          expect {
            subject
          }.to raise_error(ArgumentError)
        end

      end

      context "successfully updates" do
        before do
          allow_any_instance_of( ActionKitConnector::Client ).to(
            receive(:update_donation_page)
          )

          allow_any_instance_of( ActionKitConnector::Client ).to(
            receive(:update_petition_page)
          )
        end

        let(:params) do
          {
            type: 'update_pages',
            petition_uri: "/rest/v1/petitionpage/12853/",
            donation_uri: "/rest/v1/donationpage/12854/",
            params: {
              title: "house of cards"
            }
          }
        end

        subject do
          VCR.use_cassette('page_update_200'){ post("/message", params) }
        end

        context 'title' do
          it 'adds title suffix to petition page' do
            expect_any_instance_of( ActionKitConnector::Client ).to(
              receive(:update_petition_page).with(hash_including({title: "house of cards (Petition)"}))
            )
            expect_any_instance_of( ActionKitConnector::Client ).to(
              receive(:update_donation_page).with(hash_including({title: "house of cards (Donation)"}))
            )

            subject
          end
        end
      end
    end
  end

  describe "POST /petitionpage" do
    let(:params) do
      { type: 'create',
          params: {
          page_id: page.id,
          name: "this-page-does-not-exist-13172404",
          title: 'Foo Bar',
          url:   'http://example.com',
          language: '/rest/v1/language/100/'
        }
      }
    end

    subject { page.reload }


    describe 'form documents' do
      it 'creates a petitionform' do
        expect_any_instance_of( ActionKitConnector::Client ).to(
          receive(:create_petitionform).
          with(hash_including({
              :client_hosted=>true,
              :client_url=>"http://example.com",
              :ask_text=>"Dummy ask",
              :thank_you_text=>"Dummy thank you",
              :statement_text=>"Dummy statement",
              :page=>"https://act.sumofus.org/rest/v1/petitionpage/12574/"
            })
          )
        )

        VCR.use_cassette('page_create'){ post "/message", params }
      end


      it 'creates a donationform' do
        expect_any_instance_of( ActionKitConnector::Client ).to(
          receive(:create_donationform).
          with(hash_including({
              :client_hosted=>true,
              :client_url=>"http://example.com",
              :ask_text=>"Dummy ask",
              :thank_you_text=>"Dummy thank you",
              :statement_text=>"Dummy statement",
              :page=>"https://act.sumofus.org/rest/v1/donationpage/12575/"
            })
          )
        )

        VCR.use_cassette('page_create'){ post "/message", params }
      end
    end

    context 'payload' do
      it 'has correct properties' do
        expect_any_instance_of( ActionKitConnector::Client ).to(
          receive(:create_donation_page).
          with(hash_including(
            {
              "page_id"=> page.id.to_s,
              "name"=>"this-page-does-not-exist-13172404-donation",
              "title"=>"Foo Bar (Donation)",
              "language"=>"/rest/v1/language/100/",
              "page_type"=>"donation",
              "hpc_rule"=>"/rest/v1/donationhpcrule/22/"
            }
          )).
          and_call_original
        )

        expect_any_instance_of( ActionKitConnector::Client ).to(
          receive(:create_petition_page).
          with(hash_including({
              "page_id"=> page.id.to_s,
              "name"=>"this-page-does-not-exist-13172404-petition",
              "title"=>"Foo Bar (Petition)",
              "language"=>"/rest/v1/language/100/",
              "page_type"=>"petition"
            })
          ).and_call_original
        )

        VCR.use_cassette('page_create'){ post "/message", params }
      end
    end

    context "with successful request" do
      before do
        VCR.use_cassette('page_create') do
          post "/message", params
        end
      end

      describe 'recording AK resource to page' do
        it 'records petition resource URI' do
          expect(subject.ak_petition_resource_uri).to match( %r{https://act.sumofus.org/rest/v1/petitionpage/\d+/} )
        end

        it 'records donation resource URI' do
          expect(subject.ak_donation_resource_uri).to match( %r{https://act.sumofus.org/rest/v1/donationpage/\d+/} )
        end

        it 'records status' do
          expect(subject.status).to eq("success")
        end
      end
    end

    context "with invalid slug" do
      before do
        params[:slug] = '}not-valid-chars{'

        VCR.use_cassette('page_create_invalid') do
          post "/message", params
        end
      end

      describe 'recording AK resource to page' do
        it 'records status' do
          expect(subject.status).to eq("failed")
        end
      end
    end
  end
end

