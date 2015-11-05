require 'rails_helper'
require 'webmock/rspec'

describe AkActionCreator do
  subject{ AkActionCreator.new }

  it 'calls the endpoint for creating an action in ActionKit' do
    stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/action/')

    subject.create_action 'test_page', {email: 'fake_email@sumofus.org'}
    expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/action/')
  end

end

