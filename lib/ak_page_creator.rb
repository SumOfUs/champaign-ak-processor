class AkPageCreator
  include Ak::Client

  class << self
    def create_page(params)
      new(params).create_page
    end
  end

  def initialize(params)
    @params = params
  end

  def create_page
    case page_type
    when 'donation'
      page, error = process_create_request(create_donation_page)
      create_donationform(page) unless error
    when 'petition'
      page, error = process_create_request(create_petition_page)
      create_petitionform(page) unless error
    end
  end

  def process_create_request(request)
    page = Page.find(page_id)

    error = false

    case request.response
      when Net::HTTPCreated
        page.update(
          "ak_#{page_type}_resource_uri" => request.headers['location'],
          status: 'success'
        )
      when Net::HTTPBadRequest
        page.update(
          status: 'failed',
          messages: request.parsed_response
        )
        error = true
    end

    AkLog.create({
      resource:        'create',
      response_body:   request.response.body,
      response_status: request.response.code
    })

    [page, error]
  end

  private

  def create_donationform(page)
    client.create_donationform( form_params(page).merge(page: page.ak_donation_resource_uri))
  end

  def create_petitionform(page)
    client.create_petitionform( form_params(page).merge(page: page.ak_petition_resource_uri))
  end

  def form_params(page)
    {
      client_hosted: true,
      client_url:     @params['url'],
      ask_text:       'Dummy ask',
      thank_you_text: 'Dummy thank you',
      statement_text: 'Dummy statement'
    }
  end

  def create_petition_page
    client.create_petition_page( @params.merge( name_and_title( :petition ) ) )
  end

  def create_donation_page
    client.create_donation_page( @params.merge(name_and_title( :donation )).
      merge({
        hpc_rule: "/rest/v1/donationhpcrule/#{ENV['HPC_RULE_ID']}/"
      })
    )
  end

  def name_and_title(type)
    {
      name:   "#{@params[:name]}-#{type}",
      title:  "#{@params[:title]} (#{type.capitalize})"
    }
  end

  def page_type
    @params[:page_type]
  end

  def page_id
    @params[:page_id]
  end
end

