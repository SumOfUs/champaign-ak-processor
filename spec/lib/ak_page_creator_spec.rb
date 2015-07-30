require 'rails_helper'
require 'webmock/rspec'

describe AkPageCreator do
  let(:hostname) { 'http://localhost' }
  let(:username) { 'fake_username' }
  let(:password) { 'fake_password' }
  let(:creator) { AkPageCreator.new hostname, username, password }

  it 'should call the endpoint for creating a petition page' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/petitionpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        '/rest/v1/language/100/',
                        'localhost',
                        creator.page_types[:petition]

    expect(WebMock).to have_requested(:post, 'http://fake_username:fake_password@localhost/petitionpage/')
  end

  it 'should call the endpoint for creating a donation page' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/donationpage/')
    creator.create_page 'fake-test-page',
                        'Fake Test Page',
                        '/rest/v1/language/100/',
                        'localhost',
                        creator.page_types[:donation]

    expect(WebMock).to have_requested(:post, 'http://fake_username:fake_password@localhost/donationpage/')
  end
end
