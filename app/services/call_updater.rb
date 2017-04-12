class CallUpdater
  def self.run(params)
    ak_action_id = CallRepository.get(params[:meta][:call_id])
    ActionUpdater.run(ak_action_id, params)
  end
end