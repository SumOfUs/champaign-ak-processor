class PageParamConverter

  def initialize(params)
    @params = params
  end

  def get_params_for_petition_page
    {
        name: @params[:slug], # We don't change the slug for petitions because this keeps old petitions viable.
        title: self.convert_title_for_petition(@params[:title]),
        page_id: @params[:id],
        language_uri: self.find_language_uri_code(@params[:language_code]),
        url: self.find_absolute_page_url(@params[:slug]),
        page_type: AkPageCreator.page_types[:petition]
    }
  end

  def get_params_for_donation_page
    {
        name: self.convert_slug_for_donation(@params[:slug]),
        title: self.convert_title_for_donation(@params[:title]),
        page_id: @params[:id],
        language_uri: self.find_language_uri_code(@params[:language_code]),
        url: self.find_absolute_page_url(@params[:slug]),
        page_type: AkPageCreator.page_types[:donation]
    }
  end

  protected
  def convert_slug_for_donation(slug)
    slug + '-donation'
  end

  def convert_title_for_petition(title)
    title + ' [Petition]'
  end

  def convert_title_for_donation(title)
    title + ' [Donation]'
  end

  def find_language_uri_code(lang_code)
    AkLanguageUriFinder.get_ak_language_uri(lang_code)
  end

  def find_absolute_page_url(slug)
    ENV['ROOT_ACTION_URL'] + slug
  end
end
