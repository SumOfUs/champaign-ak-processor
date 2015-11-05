class AkPageCreator < AkCreator
  SUPPORTED_PAGE_TYPES = {
    petition: 'petition',
    donation: 'donation'
  }

  class << self
    def create_page(name, title, language, url, type, page_id)
      new.create_page(name, title, language, url, type, page_id)
    end
  end

  def create_page(name, title, language, url, type, page_id)
    translated_language = AkLanguageUriFinder.get_ak_language_uri(language)
    case type
      when SUPPORTED_PAGE_TYPES[:donation]
        self.process_create_request(
            self.create_donation_page(name, title, translated_language, url),
            page_id
        )
      when SUPPORTED_PAGE_TYPES[:petition]
        self.process_create_request(
            self.create_petition_page(name, title, translated_language, url),
            page_id
        )
      else
        # do nothing, at least for now.
    end
  end

  def process_create_request(request, page_id)
    page = Page.find(page_id)

    if request.response.class == Net::HTTPCreated
      page.status = 'success'
      page.save
    elsif request.response.class == Net::HTTPBadRequest
      page.status = 'failed'
      page.messages = request.parsed_response.to_json
      page.save
    end

    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })
  end

  def self.page_types
    SUPPORTED_PAGE_TYPES
  end

  protected
  def create_petition_page(name, title, language, url)
    client.create_petition_page name, title, language, url
  end

  def create_donation_page(name, title, language, url)
    client.create_donation_page name, title, language, url
  end
end

