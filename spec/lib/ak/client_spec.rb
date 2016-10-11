require 'rails_helper'

describe Ak::Client do
  describe 'client' do
    it 'instantiates with credentials' do
      expect(Ak::Client.client.credentials).to eq({password: ENV['AK_PASSWORD'], username: ENV['AK_USERNAME']})
    end
  end
end

