class AkActionCreator < AkCreator
  def create_action(page_name, email, additional_fields = {})
    @connection.create_action page_name, email, additional_fields
  end
end
