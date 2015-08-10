require 'rails_helper'
require 'webmock/rspec'

describe AkPageCreator do
  let(:hostname) { 'http://localhost' }
  let(:username) { 'fake_username' }
  let(:password) { 'fake_password' }
  let(:creator) { AkPageCreator.new hostname, username, password }
  let(:page) {
    language = Language.create! language_code: 'en', language_name: 'English'
    CampaignPage.create! title: 'A nice title', language_id: language.id,
                         slug: 'test-slug', active: true, featured: false
  }
  let(:good_response) { {status: [201, 'Created']} }
  let(:bad_messages) { {error: 'A bad thing happened'} }
  let(:bad_response) { {status: [400, 'Bad Request'], body: bad_messages.to_json} }

  it 'calls the endpoint for creating a petition page' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/petitionpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'localhost',
                        creator.page_types[:petition],
                        page.id

    expect(WebMock).to have_requested(:post, 'http://fake_username:fake_password@localhost/petitionpage/')
  end

  it 'calls the endpoint for creating a donation page' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/donationpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'localhost',
                        creator.page_types[:donation],
                        page.id

    expect(WebMock).to have_requested(:post, 'http://fake_username:fake_password@localhost/donationpage/')
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/petitionpage/').to_return(good_response)
    saved_page = page
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'localhost',
                        creator.page_types[:petition],
                        page.id

    expect(CampaignPage.find(saved_page.id).status).to eq('success')
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/petitionpage/').to_return(bad_response)
    saved_page = page
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'localhost',
                        creator.page_types[:petition],
                        page.id

    refreshed_page = CampaignPage.find(saved_page.id)
    expect(refreshed_page.status).to eq('failed')
    expect(refreshed_page.messages).to eq(bad_messages.to_json)
  end
end
