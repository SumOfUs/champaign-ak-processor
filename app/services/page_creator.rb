class PageCreator
  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
    @page_id = params.fetch(:page_id)
  end

  def run
    @page = Page.find @page_id
    success = Donation.run(@page, @params)
    create_donation_form if success
    success = Petition.run(@page, @params)
    create_petition_form if success
  end

  def create_donation_form
    params = { url: @params[:url], page: @page.ak_donation_resource_uri }
    FormCreator::Donation.run(params)
  end

  def create_petition_form
    params = { url: @params[:url], page: @page.ak_petition_resource_uri }
    FormCreator::Petition.run(params)
  end

  class Base
    include Ak::Client

    def self.run(page, params)
      new(page, params).run
    end

    def initialize(page, params)
      @page, @params = page, params
    end

    private

    def handle_response(response)
      case response.response
        when Net::HTTPCreated
          @page.update!(
            "ak_#{page_type}_resource_uri" => response.headers['location'],
            status: 'success'
          )
          true
        when Net::HTTPBadRequest
          @page.update!(
            status: 'failed',
            messages: response.parsed_response
          )
          false
      end
    end

    def sanitized_params
      params = @params.merge(
        name:   "#{@params[:name]}-#{page_type}",
        title:  "#{@params[:title]} (#{page_type.capitalize})",
        page_type: page_type,
        multilingual_campaign: multilingual_campaign_uri
      )
      params.delete(:campaign_id)
      params
    end

    def multilingual_campaign_uri
      CampaignRepository.get(@params[:campaign_id])
    end

    def page_type
      raise "Not Implemented"
    end
  end

  class Petition < Base
    def run
      response = client.create_petition_page(sanitized_params)
      handle_response(response)
    end

    def page_type
      'petition'
    end
  end

  class Donation < Base
    def run
      response = client.create_donation_page(sanitized_params)
      handle_response(response)
    end

    private

    def page_type
      'donation'
    end

    def sanitized_params
      super.merge(
        hpc_rule: "/rest/v1/donationhpcrule/#{ENV['HPC_RULE_ID']}/"
      )
    end
  end
end
