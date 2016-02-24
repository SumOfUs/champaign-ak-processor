require 'rails_helper'

describe "REST" do
  let(:page) { Page.create(title: 'Foo', slug: 'foo-bar') }

  describe "POST /petitionpage" do
    let(:params) do
      { type: 'create',
        params: {
          page_id: page.id,
          name: "this-page-does-not-exist-13172402",
          title: 'Foo Bar',
          language: '/rest/v1/language/100/'
        }
      }
    end

    subject { page.reload }

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

