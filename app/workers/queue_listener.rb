class QueueListener
  CREATE_MESSAGE_TYPE = 'create'
  ACTION_MESSAGE_TYPE = 'action'
  UPDATE_PAGE_MESSAGE_TYPE = 'update'
  DONATION_ACTION_MESSAGE_TYPE = 'donation'

  def perform(sqs_message, params)
    case params[:type]
      when UPDATE_PAGE_MESSAGE_TYPE
        update_resource(params)
      when CREATE_MESSAGE_TYPE
        converter = PageParamConverter.new(params[:params])
        # We blindly create both page types, because we can use pages for
        # both petitions and donations, and there's essentially no overhead to doing
        # this on our end.
        create_page converter.get_params_for_petition_page
        create_page converter.get_params_for_donation_page
      when ACTION_MESSAGE_TYPE
        # We pass the rest of message params to `create_action` in order to allow for more fields than
        # just the email address being passed along for the user. `create_action` can filter the
        # params on its own, so we don't have to worry about passing along invalid fields.
        create_action(params)
      when DONATION_ACTION_MESSAGE_TYPE
        create_donation(params)
      else
        raise ArgumentError, "Unsupported message type: #{params[:type]}"
    end
  end

  private

  def create_action(params)
    AkActionCreator.create_action(params[:params][:slug], params[:params][:body])
  end

  def update_resource(params)
    Ak::Updater.update(uri: params[:uri], body: params[:params])
  end

  def create_donation(params)
    AkDonationActionCreator.create_donation_action(params[:params])
  end

  def create_page(params)
    AkPageCreator.create_page(
        params[:name],
        params[:title],
        params[:language],
        params[:url],
        params[:page_type],
        params[:page_id]
    )
  end
end

