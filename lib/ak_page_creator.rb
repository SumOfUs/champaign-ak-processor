class AkPageCreator < AkCreator
  SUPPORTED_PAGE_TYPES = {petition: 'petition', donation: 'donation'}

  def create_page(name, title, language, url, type, campaign_page_id)
    translated_language = AkLanguageUriFinder.get_ak_language_uri(language)
    case type
      when SUPPORTED_PAGE_TYPES[:donation]
        self.process_create_request(
            self.create_donation_page(name, title, translated_language, url),
            campaign_page_id
        )
      when SUPPORTED_PAGE_TYPES[:petition]
        self.process_create_request(
            self.create_petition_page(name, title, translated_language, url),
            campaign_page_id
        )
      else
        # do nothing, at least for now.
    end
  end

  def process_create_request(request, campaign_page_id)
    page = CampaignPage.find campaign_page_id
    if request.response.class == Net::HTTPCreated
      page.status = 'success'
      page.save
    elsif request.response.class == Net::HTTPBadRequest
      page.status = 'failed'
      page.messages = request.parsed_response.to_json
      page.save
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
