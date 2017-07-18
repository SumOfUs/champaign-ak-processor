require 'rails_helper'

describe ActionUpdater do

  let(:params) do
    {
      params: {},
      meta: {
        action_id: 123
      }
    }
  end

  let(:successful_response) { double('success?' => true) }

  before do
    allow(Ak::Client.client).to receive(:update_petition_action).
                                and_return(successful_response)

    ActionRepository.set(123,
      ak_id: 456, page_ak_uri: 'http://some.url', member_email: 'omar@sumofus.org'
    )
  end

  it 'updates the ak action with the custom params on the `fields` key, and removing the `action` prefix' do
    params[:params][:action_custom_field] = 'custom_value'
    expect(Ak::Client.client).to receive(:update_petition_action).
      with('456', fields: { custom_field: 'custom_value' }).
      and_return(successful_response)

    ActionUpdater.run(params)
  end

  it 'updates the ak action with the passed params flattening any nested objects' do
    params[:params][:action_target] = { name: 'John', phone: '911' }
    expect(Ak::Client.client).to receive(:update_petition_action).
      with('456', fields: { target_name: 'John', target_phone: '911' }).
      and_return(successful_response)

    ActionUpdater.run(params)
  end

end