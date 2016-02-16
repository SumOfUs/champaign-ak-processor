require 'rails_helper'

describe AkPageCreator do
  let(:language){
    Language.create! code: 'en', name: 'English'
  }

  let(:page){
    Page.create! title: 'A nice title', language_id: language.id, slug: 'test-slug', active: true, featured: false
  }

  let(:good_response){ {status: [201, 'Created']} }
  let(:bad_messages) { {error: 'A bad thing happened'} }
  let(:bad_response) { {status: [400, 'Bad Request'], body: bad_messages.to_json} }

  let(:params) do
    {
      page_type:    page_type,
      page_id:      page.id,
      name:        'my-petition',
      title:       'My Petition',
      language:    '/v1/rest/language/1234'
    }
  end

  let(:page_type) { 'petition' }

  subject(:creator) { described_class.new(params) }

  context 'petition page' do
    it 'calls the endpoint for creating a petition page' do
      stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/')
      subject.create_page
      expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/')
    end
  end

  context 'donation page' do
    let(:page_type) { 'donation' }

    it 'calls the endpoint for creating a donation page' do
      stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/donationpage/')
      subject.create_page 
      expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/donationpage/')
    end
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/').to_return(good_response)
    subject.create_page
    expect(page.reload.status).to eq('success')
  end

  it 'correctly sets a successful status' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/petitionpage/').to_return(bad_response)
    subject.create_page
    expect(page.reload.status).to eq('failed')
    expect(page.messages).to eq(bad_messages.to_json)
  end
end

