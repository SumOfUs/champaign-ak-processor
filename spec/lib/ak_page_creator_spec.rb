require 'rails_helper'
require 'webmock/rspec'

describe AkPageCreator do
  let(:creator) { AkPageCreator.new}

  let(:page) {
    language = Language.create! code: 'en', name: 'English'
    Page.create! title: 'A nice title', language_id: language.id, slug: 'test-slug', active: true, featured: false
  }

  let(:good_response){ {status: [201, 'Created']} }
  let(:bad_messages) { {error: 'A bad thing happened'} }
  let(:bad_response) { {status: [400, 'Bad Request'], body: bad_messages.to_json} }

  it 'calls the endpoint for creating a petition page' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'act.sumofus.org/rest/v1',
                        AkPageCreator.page_types[:petition],
                        page.id

    expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/')
  end

  it 'calls the endpoint for creating a donation page' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/donationpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'act.sumofus.org/rest/v1',
                        AkPageCreator.page_types[:donation],
                        page.id

    expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/donationpage/')
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/').to_return(good_response)
    saved_page = page
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'act.sumofus.org/rest/v1',
                        AkPageCreator.page_types[:petition],
                        page.id

    expect(Page.find(saved_page.id).status).to eq('success')
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/').to_return(bad_response)
    saved_page = page
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        'en',
                        'act.sumofus.org/rest/v1',
                        AkPageCreator.page_types[:petition],
                        page.id

    refreshed_page = Page.find(saved_page.id)
    expect(refreshed_page.status).to eq('failed')
    expect(refreshed_page.messages).to eq(bad_messages.to_json)
  end
end
