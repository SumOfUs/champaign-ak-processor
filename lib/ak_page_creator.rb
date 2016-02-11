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
        process_create_request(create_donation_page)
    when 'petition'
        process_create_request(create_petition_page)
    end
  end

  def process_create_request(request)
    page = Page.find(page_id)

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
    end

    AkLog.create({
      resource: 'create',
      response_body: request.response.body,
      response_status: request.response.code
    })
  end

  private

  def create_petition_page
    name = "#{@params[:name]}-petition"
    client.create_petition_page( @params.merge(name: name) )
  end

  def create_donation_page
    name = "#{@params[:name]}-donation"
    client.create_donation_page( @params.merge(name: name) )
  end

  def page_type
    @params[:page_type]
  end

  def page_id
    @params[:page_id]
  end
end

