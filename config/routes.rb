Rails.application.routes.draw do
  post '/message' => 'message_handler#handle'
  post '/update_share_analytics' => 'message_handler#dispatch_shareprogress_update'
end
