require 'rails_helper'
require 'webmock/rspec'

describe AkActionCreator do
  let(:hostname) { 'http://localhost' }
  let(:username) { 'fake_username' }
  let(:password) { 'fake_password' }
  let(:creator) { AkActionCreator.new hostname, username, password }

  it 'calls the endpoint for creating an action in ActionKit' do
    stub_request(:post, 'http://fake_username:fake_password@localhost/action/')

    creator.create_action 'test_page', 'fake_email@sumofus.org'
    expect(WebMock).to have_requested(:post, 'http://fake_username:fake_password@localhost/action/')
  end

end
