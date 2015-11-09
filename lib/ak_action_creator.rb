module ActionKitConnector
  class Connector
    def create_action(page_name, params = {})
      options = {
        basic_auth: auth,
        body: params.merge( page: page_name ),
        format: :json
      }

      self.class.post("#{base_url}/action/", options)
    end
  end
end

class AkActionCreator < AkCreator
  class << self
    def create_action(page_name, params)
      new.create_action(page_name, params)
    end
  end

  def create_action(page_name, params)
    request = client.create_action(page_name, params)

    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })
  end
end

