class AkDonationActionCreator < AkCreator
  class << self
    def create_donation_action(options)
      new.create_donation_action(options)
    end
  end

  def create_donation_action(options)
    request = client.create_donation_action(options)
    AkLog.create(resource: 'donation', response_body: request.response.body, response_status: request.response.code)
  end
end