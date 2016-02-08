require 'rails_helper'

describe "Logging API requests" do
  let(:page) { Page.create(title: 'Foo', slug: 'foo-bar') }

  context "Updating Page Resource" do
    let(:params) do
      { type: 'update',
        uri: "https://act.sumofus.org/rest/v1/petitionpage/8769/",
        params: {
          title: 'Foo Bar',
          tags: ["/rest/v1/tag/878/"]
        }
      }
    end

    context "204 response" do
      it "updates resource" do
        VCR.use_cassette('update_resource_204') do
          expect(post "/message", params).to eq(200)
        end
      end

    end
  end

  context "Creating Page Resource" do
    let(:params) do
      { type: 'create',
        params: {
          id: page.id,
          slug: 'slug-taken',
          title: 'Foo Bar',
          language_code: 'en'
        }
      }
    end

    context "400 response" do
      it "logs failure" do
        VCR.use_cassette('create_page_400') do
          post "/message", params
          petition_log = AkLog.first
          donation_log = AkLog.last
          expect(petition_log.response_status).to eq('400')
          expect(donation_log.response_status).to eq('400')

          expect(petition_log.response_body).to eq("{\"petitionpage\": {\"name\": [\"Page with this Short name already exists.\"]}}")
          expect(donation_log.response_body).to eq("{\"donationpage\": {\"name\": [\"Page with this Short name already exists.\"]}}")
        end
      end

      it 'update pages' do
        VCR.use_cassette('create_page_400') do
          post "/message", params

          expect(page.reload.status).to eq('failed')
        end
      end
    end

    context "201 response" do
      let(:params) do
        { type: 'create',
          params: {
            id: page.id,
            slug: 'slug-available',
            title: 'Foo Bar',
            language_code: 'en'
          }
        }
      end

      it 'updates page model' do
        VCR.use_cassette('create_page_201') do
          post "/message", params

          expect(page.reload.status).to eq('success')
          expect(page.ak_donation_resource_uri).to eq('https://act.sumofus.org/rest/v1/donationpage/8770/')
          expect(page.ak_petition_resource_uri).to eq('https://act.sumofus.org/rest/v1/petitionpage/8769/')
        end
      end

      it "logs success" do
        VCR.use_cassette('create_page_201') do
          post "/message", params
          log = AkLog.first

          expect(log.response_body).to eq(nil)
          expect(log.response_status).to eq('201')
        end
      end
    end
  end

  context "Action Creation" do
    context "201 response" do
      let(:params) do
        { type: 'action',
          params: {
            slug: 'foo-bar',
            body: {
              email: "foo@example.com"
            }
          }
        }
      end

      it "logs success" do
        VCR.use_cassette('create_action_201') do
          post "/message", params
          log = AkLog.first

          expect(log.response_status).to eq('201')
        end
      end
    end

    context "400 response" do
      let(:params) do
        { type: 'action',
          params: {
            slug: 'i-do-not-exist',
            body: {
              email: "foo@example.com"
            }
          }
        }
      end

      it "logs failure" do
        VCR.use_cassette('create_action_400') do
          post "/message", params
          log = AkLog.first

          expect(log.response_status).to eq('400')
          expect(log.response_body).to eq("{\"page\": \"Unable to find a page for processing. You sent page=i-do-not-exist.\"}")
        end
      end
    end
  end
end

