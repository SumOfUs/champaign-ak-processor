require 'rails_helper'

describe PageParamConverter do
  let(:language_code) { 'en' }
  let(:slug) { 'a-test-slug' }
  let(:title) { 'A test title' }
  let(:page_id) { 1 }
  let(:created_language) {
    Language.create! code: language_code, name: 'English'
  }
  let(:params) {
    {
        slug: slug,
        title: title,
        id: page_id,
        language_code: 'en'
    }
  }
  it 'gets params for petition pages' do
    expected_params = {
        name: slug,
        title: title + ' [Petition]',
        page_id: page_id,
        language_uri: AkLanguageUriFinder.get_ak_language_uri(language_code),
        url: ENV['ROOT_ACTION_URL'] + slug,
        page_type: AkPageCreator.page_types[:petition]
    }
    expect(PageParamConverter.new(params).get_params_for_petition_page).to eq(expected_params)
  end

  it 'gets params for donation pages' do
    expected_params = {
        name: slug + '-donation',
        title: title + ' [Donation]',
        page_id: page_id,
        language_uri: AkLanguageUriFinder.get_ak_language_uri(language_code),
        url: ENV['ROOT_ACTION_URL'] + slug,
        page_type: AkPageCreator.page_types[:donation]
    }
    expect(PageParamConverter.new(params).get_params_for_donation_page).to eq(expected_params)
  end
end
