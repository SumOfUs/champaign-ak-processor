class FormCreator
  include Ak::Client

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @champaign_uri = params[:champaign_uri]
    @page_ak_uri = params[:page_ak_uri]
  end

  private

  def sanitized_params
    {
      page:           @page_ak_uri,
      client_hosted:  true,
      client_url:     @champaign_uri,
      ask_text:       'Dummy ask',
      thank_you_text: 'Dummy thank you',
      statement_text: 'Dummy statement'
    }
  end

  class Petition < FormCreator
    def run
      response = client.create_petitionform(sanitized_params)
      if !response.success?
        Rails.logger.error("Failure creating petition fomr - code: #{response.code}, body: #{response.body}")
      end
      response
    end
  end

  class Donation < FormCreator
    def run
      response = client.create_donationform(sanitized_params)
      if !response.success?
        Rails.logger.error("Failure creating donation form - code: #{response.code}, body: #{response.body}")
      end
      response
    end
  end

end
