Rails.application.routes.draw do
  post '/message' => 'message_handler#handle'
end
