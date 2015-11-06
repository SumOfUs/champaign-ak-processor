require 'rails_helper'

describe "Logging API requests" do
  context "Page Creation" do
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

    let(:page) { Page.create(title: 'Foo', slug: 'foo-bar') }

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

