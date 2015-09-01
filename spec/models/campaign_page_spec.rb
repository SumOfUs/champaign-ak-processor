require 'rails_helper'

describe CampaignPage do
  it {should respond_to :status}
  it {should respond_to :messages}

  let(:page) {
    language = Language.create! code: 'en', name: 'English'
    CampaignPage.create! title: 'A nice title', language_id: language.id,
                         slug: 'test-slug', active: true, featured: false
  }
  it 'has a default status of pending' do
    expect(page.status).to eql('pending')
  end
end
