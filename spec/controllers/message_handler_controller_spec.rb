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
      post :handle, foo: :bar
    end

    it 'renders nothing' do
      expect(response.body).to eq('')
      post :dispatch_shareprogress_update
    end
  end

  describe 'POST#displatch_shareprogress_update' do
    before do
      allow(ShareAnalyticsUpdater::EnqueueJobs).to receive(:run)
    end

    it 'enqueues jobs' do
      expect(ShareAnalyticsUpdater::EnqueueJobs).to receive(:run)
      post :dispatch_shareprogress_update
    end

    it 'renders nothing' do
      expect(response.body).to eq('')
      post :dispatch_shareprogress_update
    end
  end
end

