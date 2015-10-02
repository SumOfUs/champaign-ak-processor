class AkActionCreator < AkCreator
  def create_action(page_name, params)
    request = @connection.create_action(page_name, params[:email], params)
    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })

  end
end
