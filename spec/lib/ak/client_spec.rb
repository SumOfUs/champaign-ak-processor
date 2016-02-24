require 'rails_helper'

describe Ak::Client do
  describe 'client' do
    before do
      allow(ENV).to receive(:[]).with("AK_USERNAME"){"foo"}
      allow(ENV).to receive(:[]).with("AK_PASSWORD"){"bar"}
      allow(ENV).to receive(:[]).with("AK_HOST"){"http://foo.com"}
    end

    it 'instantiates with credentials' do
      expect(Ak::Client.client.credentials).to eq({password: 'bar', username: 'foo'})
    end
  end
end

