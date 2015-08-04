class AkPageCreator < AkCreator
  SUPPORTED_PAGE_TYPES = {petition: 'petition', donation: 'donation'}

  def create_page(name, title, language, url, type)
    translated_language = AkLanguageUriFinder.get_ak_language_uri(language)
    case type
      when SUPPORTED_PAGE_TYPES[:donation]
        self.create_donation_page name, title, translated_language, url
      when SUPPORTED_PAGE_TYPES[:petition]
        self.create_petition_page name, title, translated_language, url
      else
        # do nothing
    end
  end

  def process_request(request)

    if request.response.code == 201

    end
  end

  def page_types
    SUPPORTED_PAGE_TYPES
  end

  protected
  def create_petition_page(name, title, language, url)
    @connection.create_petition_page name, title, language, url
  end

  def create_donation_page(name, title, language, url)
    @connection.create_donation_page name, title, language, url
  end
end
