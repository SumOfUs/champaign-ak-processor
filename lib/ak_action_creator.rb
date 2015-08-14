class AkActionCreator < AkCreator
  def create_action(page_name, email)
    @connection.create_action page_name, email
  end
end
