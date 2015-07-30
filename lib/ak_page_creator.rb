class AkPageCreator < AkCreator
  SUPPORTED_PAGE_TYPES = {petition: 'petition', donation: 'donation'}

  def create_page(name, title, language, url, type)
    if type == SUPPORTED_PAGE_TYPES[:donation]
      self.create_donation_page name, title, language, url
    elsif type == SUPPORTED_PAGE_TYPES[:petition]
      self.create_petition_page name, title, language, url
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
