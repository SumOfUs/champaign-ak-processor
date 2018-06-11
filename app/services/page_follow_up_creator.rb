class PageFollowUpCreator
  class Error < StandardError; end
  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    response = Ak::Client.client.create_page_follow_up(create_params)

    if !response.success?
      raise Error.new("HTTP Response code: #{response.code}, body: #{response.body}")
    end
  end

  private

  def create_params
    {
      url:             "https://not.used.com",
      send_confirmation: true,
      page:            page_ak_uri,
      email_wrapper:   email_wrapper,
      email_from_line: email_from_line,
      email_subject:   I18n.t('page_follow_up.email_subject', locale: language_code),
      email_body:      I18n.t('page_follow_up.email_body', locale: language_code)
    }
  end


  def page_ak_uri
    @params[:page_ak_uri] || raise('page_ak_uri must be present')
  end

  def email_wrapper
    ENV["PFU_#{language_code.upcase}_EMAIL_WRAPPER_URI"] ||
      raise("Email wrapper not set for #{language_code}")
  end

  def email_from_line
    ENV['PFU_EMAIL_FROM_LINE_URI'] || raise('Email from line not set')
  end

  def language_code
    @language_code ||= @params[:language_code] || 'en'
  end
end
