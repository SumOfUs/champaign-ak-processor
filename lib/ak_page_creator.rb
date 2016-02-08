class AkPageCreator < AkCreator
  SUPPORTED_PAGE_TYPES = {
    petition: 'petition',
    donation: 'donation'
  }

  class << self
    def create_page(name, title, language, url, type, page_id)
      new.create_page(name, title, language, url, type, page_id)
    end

    def page_types
      SUPPORTED_PAGE_TYPES
    end
  end

  def create_page(name, title, language, url, type, page_id)
    translated_language = AkLanguageUriFinder.get_ak_language_uri(language)

    case type
      when SUPPORTED_PAGE_TYPES[:donation]
        process_create_request(
          create_donation_page(name, title, translated_language, url),
          page_id,
          type
        )
      when SUPPORTED_PAGE_TYPES[:petition]
        process_create_request(
          create_petition_page(name, title, translated_language, url),
          page_id,
          type
        )
    end
  end

  def process_create_request(request, page_id, type)
    page = Page.find(page_id)

    case request.response
      when Net::HTTPCreated
        page.update(
          "ak_#{type}_resource_uri" => request.headers['location'],
          status: 'success'
        )
      when Net::HTTPBadRequest
        page.update(
          status: 'failed',
          messages: request.parsed_response.to_json
        )
    end

    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })
  end

  private

  def create_petition_page(name, title, language, url)
    client.create_petition_page name, title, language, url
  end

  def create_donation_page(name, title, language, url)
    client.create_donation_page name, title, language, url
  end
end

