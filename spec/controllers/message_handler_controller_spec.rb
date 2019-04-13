require 'rails_helper'

describe MessageHandlerController do
  describe 'POST#handle' do
    let(:queue) { double('queue') }

    before do
      allow(QueueListener).to receive(:new){ queue }
      allow(queue).to receive(:perform)
    end

    it 'delegates to queue listener class' do
      expect(queue).to receive(:perform).with(nil, hash_including({'foo' => 'bar'}))
      post :handle, params: { foo: :bar }
    end

    it 'renders nothing' do
      expect(response.body).to eq('')
      post :handle
    end
  end
end

