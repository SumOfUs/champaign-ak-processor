class FormCreator
  include Ak::Client

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  private

  def sanitized_params
    {
      page:           @params[:page],
      client_hosted:  true,
      client_url:     @params[:url],
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
