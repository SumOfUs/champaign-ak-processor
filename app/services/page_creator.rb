class PageCreator
  class Error < StandardError; end

  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
    @page_id = params.fetch(:page_id)
  end

  def run
    @page = Page.find @page_id
    Donation.run(@page, @params)
    Petition.run(@page, @params)
    PageFollowUpCreator.run(
        page_ak_uri:   @page.ak_donation_resource_uri,
        language_code: @page.language.try(:code)
    )
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

    def page_exists
      !@page.send("ak_#{page_type}_resource_uri").blank?
    end

    def handle_response(response)
      if !response.success?
        page_update = {status: 'failed', messages: response.parsed_response}
        Rails.logger.error("HTTP Response code: #{response.code}, body: #{response.body}")
      else
        page_update = {
            "ak_#{page_type}_resource_uri" => response.headers['location'],
            "status" => "success"
        }.with_indifferent_access
      end
      @page.update!(page_update)
      return response
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
      self.class.name.demodulize.underscore
    end
  end

  class Petition < Base
    def run
      return if page_exists
      response = handle_response(client.create_petition_page(sanitized_params))
      return response unless response.success?
      FormCreator::Petition.run(champaign_uri: @params[:url], page_ak_uri: @page.ak_petition_resource_uri)
    end

  end

  class Donation < Base
    def run
      return if page_exists
      response = handle_response(client.create_donation_page(sanitized_params))
      return response unless response.success?
      FormCreator::Donation.run(champaign_uri: @params[:url], page_ak_uri: @page.ak_donation_resource_uri)
    end

    private

    def sanitized_params
      super.merge(
        hpc_rule: "/rest/v1/donationhpcrule/#{ENV['HPC_RULE_ID']}/"
      )
    end
  end
end
