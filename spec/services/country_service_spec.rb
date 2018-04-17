require 'rails_helper'

describe CountryService do
  before do
    allow(GetConstituency).to receive(:for){ 'Brighton' }
  end

  it 'gets constituency for the United Kingdom' do
    data = {
      params: {
        country: 'United Kingdom',
        postal: 'BN1 3JG'
      }
    }

    CountryService.extend_with_local_data(data)
    expect(GetConstituency).to have_received(:for).with('BN1 3JG')
    expect(data[:params][:user_uk_parliamentary_constituency]).to eq('Brighton')
  end
end
