require 'rails_helper'

describe Ak::Client do
  describe 'client' do
    it 'instantiates with credentials' do
      expect(Ak::Client.client.credentials).to eq({password: 'fake_password', username: 'fake_username'})
    end
  end
end

