require 'aws-sdk'

class GetConstituency
  def self.for(postcode, client = nil)
    new(postcode, client).get
  end

  def initialize(postcode, client)
    @postcode = postcode&.downcase&.gsub(/\s/, '')
    @client = client || Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])
  end

  def get
    @client.get_item(options).item&.fetch('constituency', nil)
  end

  private

  def options
    {
      table_name: table_name,
      key: {
        "postcode" => {
          s: @postcode
        }
      }
    }
  end

  def table_name
    ENV['CONSTITUENCIES_TABLE']
  end
end
