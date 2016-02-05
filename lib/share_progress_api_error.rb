class ShareProgressApiError < StandardError
  attr_reader :sp_api_error

  def initialize(sp_api_error)
    super
    @sp_api_error = sp_api_error
  end
end
