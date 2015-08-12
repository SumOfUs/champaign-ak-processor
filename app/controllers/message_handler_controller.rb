class MessageHandlerController < ApplicationController
  CREATE_MESSAGE_TYPE = 'create'
  ACTION_MESSAGE_TYPE = 'action'

  before_action :initialize_creators

  def handle
    message_params = params[:params]
    case params[:type]
      when CREATE_MESSAGE_TYPE
        converter = PageParamConverter.new(message_params)
        petition_params = converter.get_params_for_petition_page
        donation_params = converter.get_params_for_donation_page
        # We blindly create both page types, because we can use pages for
        # both petitions and donations, and there's essentially no overhead to doing
        # this on our end.
        @page_creator.create_page(
            petition_params[:name],
            petition_params[:title],
            petition_params[:language_uri],
            petition_params[:url],
            petition_params[:page_type],
            petition_params[:page_id]
        )
        @page_creator.create_page(
            donation_params[:name],
            donation_params[:title],
            donation_params[:language_uri],
            donation_params[:url],
            donation_params[:page_type],
            donation_params[:page_id]
        )
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
end
