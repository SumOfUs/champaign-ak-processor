require 'rails_helper'

describe QueueListener do
  subject { QueueListener.new }

  describe "#perform" do
    it 'updates' do
      expect( Ak::Updater ).to(
        receive(:update).with({ uri: 'http://example.com', body: { foo: 'bar' }})
      )

      subject.perform(nil, { type: 'update', uri: 'http://example.com', params: { foo: 'bar' } })
    end

    it 'raises for bad action' do
      expect{
        subject.perform(nil, { type: 'BAD' })
      }.to raise_error(ArgumentError)
    end
  end
end
