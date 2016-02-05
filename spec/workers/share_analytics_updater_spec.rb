require 'rails_helper'

describe ShareAnalyticsUpdater do
  describe 'update share analytics' do
    let(:page) {
      Page.create!(
          title: 'A nice title',
          language_id: (Language.create! code: 'en', name: 'English').id,
          slug: 'test-slug',
          active: true,
          featured: false
      )}
    describe 'success' do
      let!(:button){
        Share::Button.create!(
            title: 'the big red button',
            url:'sumofus.org',
            sp_type: 'facebook',
            page: page,
            sp_id: "148454"
        )}

        it 'gets new analytics from ShareProgress' do
          VCR.use_cassette('share_update_success') do
            expect { ShareAnalyticsUpdater.update_shares}.to_not raise_error
          end
        end
        it 'updates a button with stale analytics' do
          VCR.use_cassette('share_update_success') do
            expect(button.analytics).to be nil
            ShareAnalyticsUpdater.update_shares
            new_analytics=JSON.parse(Share::Button.find(button.id).analytics)
            expect(new_analytics['success']).to be true
            expect(new_analytics['response'][0].keys).to match_array(["created_at", "id", "share_types", "generations", "share_tests", "total"])
          end
        end
    end

    describe 'failure' do

      let!(:button){
        Share::Button.create!(
            title: 'the big red button',
            url:'sumofus.org',
            sp_type: 'facebook',
            page: page,
            sp_id: nil
        )}

      it 'does not store the response field in the analytics column if the response is not successful' do
        VCR.use_cassette('share_update_failure') do
          expect(Share::Button.find(button.id).sp_id).to be nil
          expect{ShareAnalyticsUpdater.update_shares}.to output(
         "ShareProgress button analytics update failed with the following message from their API: Can't find that .\n"
                                                         ).to_stdout
          expect(Share::Button.find(button.id).analytics).to be nil
        end
      end
    end
  end
end