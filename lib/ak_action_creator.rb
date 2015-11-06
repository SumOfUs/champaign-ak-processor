class AkActionCreator < AkCreator
  class << self
    def create_action(page_name, params)
      new.create_action(page_name, params)
    end
  end

  def create_action(page_name, params)
    request = client.create_action(page_name, params[:email], params)

    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })
  end
end

