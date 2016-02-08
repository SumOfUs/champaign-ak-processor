require 'rails_helper'

describe "REST" do
  let(:params) do
    {
      type: action_type,
      params: data
    }
  end

  describe 'POST /donationpush' do
    describe 'ActionKit' do

      let(:data) do
        {
          donationpage: {
            name: 'foo-bar-donation',
            payment_account: 'Default Import Stub'
          },

          order: {
            amount:         "34.00",
            card_code:      "007",
            card_num:       "4111111111111111",
            exp_date_month: "12",
            exp_date_year:  "2015",
            currency:       "GBP"
          },

          user: {
            email: 'foo+100@example.com',
            country: 'Portugal'
          }
        }
      end

      let(:action_type) { 'donation' }

      subject(:body) { JSON.parse(response.body).deep_symbolize_keys }

      before do
        VCR.use_cassette('donation_push_existing_user') do
          post '/message', params
        end
      end

      it "registers as complete" do
        expect(subject.fetch(:status)).to eq("complete")
      end

      it "registers type of action" do
        expect(subject.fetch(:type)).to eq("Donation")
      end

      describe "recorded order" do
        subject { body.fetch(:order) }

        it "has correct donation total" do
          expect(subject.fetch(:total)).to eq('34.00')
        end

        it "has currency" do
          expect(subject.fetch(:currency)).to eq('GBP')
        end

        it "has total as USD" do
          expect( Float(subject.fetch(:total_converted)) ).to be > 34.00
        end

        it "has credit card for default payment_method" do
          expect(subject.fetch(:payment_method)).to eq('cc')
        end
      end

      context 'with PayPal as payment method' do
        before do
          VCR.use_cassette('donation_push_paypal') do
            post '/message', params
          end
        end

        xit "has PayPal has payment_method" do
          expect(subject[:order][:payment_method]).to eq('PayPal')
        end
      end
    end
  end

  describe 'POST /action' do
    describe 'ActionKit' do

      let(:data) do
        {
          slug: 'foo-bar',
          body: {
            name:         "Pablo José Francisco de María",
            postal:       "W1",
            address1:     "The Lodge",
            address2:     "High Street",
            city:         "London",
            country:      "United Kingdom",
            action_age:   "101",
            action_foo:   "Foo",
            action_bar:   "Bar",
            ignored:      "ignore me",
            email:        "omar@sumofus.org",
            source:       'FB',
            akid:         '3.4234.fsdf'
          }
        }
      end

      let(:action_type) { 'action' }

      subject(:body) { JSON.parse(response.body).deep_symbolize_keys }

      context 'for valid page' do

        before do
          VCR.use_cassette("action_existing_page") do
            post '/message', params
          end
        end

        describe "recorded 'fields'" do
          subject(:fields) { body.fetch(:fields) }

          it 'ignores bad fields' do
            expect(fields[:ignored]).to be nil
          end

          it "records 'action_*' fields" do
            expect(fields).to eq({age: '101', foo: 'Foo', bar: 'Bar'})
          end
        end

        it 'records source' do
          expect(subject.fetch(:source)).to eq('FB')
        end

        it 'records mailing URI' do
          expect(subject.fetch(:mailing)).to eq('/rest/v1/mailing/3/')
        end
      end

      context 'for missing page' do
        before do
          VCR.use_cassette("action_missing_page") do
            data[:slug] = 'i-do-not-exist-anywhere'
            post '/message', params
          end
        end

        it 'cannot find page' do
          expect(subject[:page]).to match(/Unable to find a page/)
        end
      end
    end
  end
end
