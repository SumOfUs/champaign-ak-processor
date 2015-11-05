class QueueListener
  CREATE_MESSAGE_TYPE = 'create'
  ACTION_MESSAGE_TYPE = 'action'


  def perform(sqs_message, params)
    case params[:type]
      when CREATE_MESSAGE_TYPE
        converter = PageParamConverter.new(params[:params])
        # We blindly create both page types, because we can use pages for
        # both petitions and donations, and there's essentially no overhead to doing
        # this on our end.
        self.create_page converter.get_params_for_petition_page
        self.create_page converter.get_params_for_donation_page
      when ACTION_MESSAGE_TYPE
        # We pass the rest of message params to `create_action` in order to allow for more fields than
        # just the email address being passed along for the user. `create_action` can filter the
        # params on its own, so we don't have to worry about passing along invalid fields.
        QueueListener.get_action_creator.create_action(params[:params][:slug], params[:params])
      else
        # You've provided an unsupported type of message, we don't know how to handle this
    end
  end

  protected
  def get_page_creator
    @page_creator ||= AkPageCreator.new(
      ENV['AK_HOST'], ENV['AK_USERNAME'], ENV['AK_PASSWORD']
    )
  end

  def self.get_action_creator
    @action_creator ||= AkActionCreator.new(
      ENV['AK_HOST'], ENV['AK_USERNAME'], ENV['AK_PASSWORD']
    )
  end

  def create_page(params)
    self.get_page_creator.create_page(
        params[:name],
        params[:title],
        params[:language],
        params[:url],
        params[:page_type],
        params[:page_id]
    )
  end
end

