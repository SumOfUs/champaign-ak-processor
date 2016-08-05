class PageUpdater
  include Ak::Client

  attr_accessor :params

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    data = params[:params]
    data.delete(:name)
    @campaign_id = data.delete(:campaign_id)

    raise ArgumentError, "Missing resource URI for page" if params[:petition_uri].blank? and params[:donation_uri].blank?

    unless params[:petition_uri].blank?
      client.update_petition_page(add_title_and_id(data, params, 'petition'))
    end

    unless params[:donation_uri].blank?
      client.update_donation_page(add_title_and_id(data, params, 'donation'))
    end
  end

  private

  def add_title_and_id(data, params, suffix)
    data.merge({
      id: suffix.inquiry.donation? ? donation_id(params) : petition_id(params)
    }.tap do |load|
        load[:title] = suffix_title(data[:title], suffix) if data[:title]
        load[:multilingual_campaign] = multilingual_campaign_uri
      end
    )
  end

  def petition_id(params)
    extract_id(params[:petition_uri])
  end

  def donation_id(params)
    extract_id(params[:donation_uri])
  end

  def extract_id(uri)
    (uri || '').match(/(\d+)\/$/){|m| m[1] if m }
  end

  def suffix_title(title, type)
    return title if title.strip =~ %r{(#{type.capitalize})}
    "#{title} (#{type.capitalize})"
  end

  def multilingual_campaign_uri
    CampaignRepository.get(@campaign_id) if @campaign_id
  end

end
