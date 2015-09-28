class AkActionCreator < AkCreator
  def create_action(page_name, params)
    @connection.create_action(page_name, params[:email], params)
  end
end
