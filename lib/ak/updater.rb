# Monkey Patch!
# To be moved and spec'd at https://github.com/EricBoersma/actionkit_connector
module ActionKitConnector
  class Connector
    def update_resource(resource_uri, params)
      options = {
        basic_auth: self.auth,
        headers: {
          'Content-type' => 'application/json'
        },
        body: params.to_json
      }

      self.class.put(resource_uri, options)
    end
  end
end

module Ak
  class Updater
    extend Ak::Client

    class << self
      def update(uri:, body:)
        client.update_resource(uri, body)
      end
    end
  end
end

