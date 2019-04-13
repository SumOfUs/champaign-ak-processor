class MessageHandlerController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle
    response = QueueListener.new.perform(nil, params)
    render json: response, status: 200
  end

  # private

  # def params
  #   params.permit(%i[type params meta])
  # end
end

