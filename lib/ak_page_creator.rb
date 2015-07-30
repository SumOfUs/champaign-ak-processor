class AkPageCreator
  SUPPORTED_PAGE_TYPES = {petition: 'petition', donation: 'donation'}
  def initialize(host, username, password)
    @connection = ActionKitConnector::Connector.new username, password, host
  end

  def create_page(name, title, language, url, type)
    if type == SUPPORTED_PAGE_TYPES[:donation]
      self.create_donation_page name, title, language, url
    elsif type == SUPPORTED_PAGE_TYPES[:petition]
      self.create_petition_page name, title, language, url
    end
  end

  private
  def create_petition_page(name, title, language, url)
    @connection.create_petition_page name: name, title: title, lang: language, canonical_url: url
  end

  def create_donation_page(name, title, language, url)
    @connection.create_donation_page name: name, title: title, lang: language, canonical_url: url
  end
end
