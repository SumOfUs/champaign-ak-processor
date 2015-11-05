require 'rails_helper'

describe AkCreator do
  subject { AkCreator.new }

  describe 'client' do
    it 'instantiates with credentials' do
      expect(ActionKitConnector::Connector).to receive(:new).
        with("fake_username", "fake_password", "https://act.sumofus.org/rest/v1")

      subject.client
    end
  end
end

