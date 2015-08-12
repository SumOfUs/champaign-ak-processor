class MessageHandlerController < ApplicationController
  CREATE_MESSAGE_TYPE = 'create'
  ACTION_MESSAGE_TYPE = 'action'

  before_action :initialize_creators

  def handle
    message_params = params[:params]
    case params[:type]
      when CREATE_MESSAGE_TYPE
        converter = PageParamConverter.new(message_params)
        # We blindly create both page types, because we can use pages for
        # both petitions and donations, and there's essentially no overhead to doing
        # this on our end.
        self.create_page converter.get_params_for_petition_page
        self.create_page converter.get_params_for_donation_page
      when ACTION_MESSAGE_TYPE
        message_params = params[:params]
        @action_creator.create_action(message_params[:slug], message_params[:email])
      else
        # You've provided an unsupported type of message, we don't know how to handle this
    end
  end

  protected
  def initialize_creators
    @page_creator = @page_creator || AkPageCreator.new(
        ENV['AK_HOST'], ENV['AK_USERNAME'], ENV['AK_PASSWORD']
    )
    @action_creator = @action_creator || AkActionCreator.new(
        ENV['AK_HOST'], ENV['AK_USERNAME'], ENV['AK_PASSWORD']
    )
  end

  def create_page(params)
    @page_creator.create_page(
        params[:name],
        params[:title],
        params[:language_uri],
        params[:url],
        params[:page_type],
        params[:page_id]
    )
  end
end
