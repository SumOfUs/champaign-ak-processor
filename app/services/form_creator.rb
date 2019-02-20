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
      client.create_petitionform(sanitized_params)
    end
  end

  class Donation < FormCreator
    def run
      client.create_donationform(sanitized_params)
    end
  end
end
