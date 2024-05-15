require './app/lib/secrets_manager'

if Rails.env == 'production'
  ak_secrets = SecretsManager.get_value('prod/actionKitApi')
  database_secrets = SecretsManager.get_value('champaignDB')
  share_progress_secrets = SecretsManager.get_value('shareProgressApi')
  champaign_secrets = SecretsManager.get_value('champaign')
  devise_secrets = SecretsManager.get_value('prod/deviseSecret');

  ENV['AK_USERNAME'] = ak_secrets['username']
  ENV['AK_PASSWORD'] = ak_secrets['password']

  ENV['RDS_DB_NAME'] = database_secrets['dbname']
  ENV['RDS_USERNAME'] = database_secrets['username']
  ENV['RDS_PASSWORD'] = database_secrets['password']
  ENV['RDS_HOSTNAME'] = database_secrets['host']
  ENV['RDS_PORT'] = database_secrets['port'].to_s

  ENV['SHARE_PROGRESS_API_KEY'] = share_progress_secrets['apiKey']

  ENV['CHAMPAIGN_API_KEY'] = champaign_secrets['apiKey']

  ENV['DEVISE_SECRET_KEY'] = devise_secrets['secretKey']
end
