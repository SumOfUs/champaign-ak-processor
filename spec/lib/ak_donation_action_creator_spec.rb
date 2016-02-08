require 'rails_helper'
require 'webmock/rspec'

describe AkDonationActionCreator do
  subject {AkDonationActionCreator.new}

  let(:full_donation_options) {
    {
        donationpage: {
            name: 'donation',
            payment_account: 'Default Import Stub'
        },
        order: {
            amount: '1',
            card_num: '4111111111111111',
            card_code: '007',
            exp_date_month: '01',
            exp_date_year: '2016'
        },
        user: {
            email: 'eric@sumofus.org',
            country: 'United States',
        }
    }
  }

  it 'calls the endpoint for creating a donation action in ActionKit' do
    VCR.use_cassette('AkDonationActionCreator') do
      stub_request(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/action/')
      subject.create_donation_action(full_donation_options)
      expect(WebMock).to have_requested(:post, 'https://fake_username:fake_password@act.sumofus.org/rest/v1/donationpush/')
    end
  end
end
