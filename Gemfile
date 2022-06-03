source 'https://rubygems.org'

ruby '2.6.2'
gem 'rails', '~> 5.0'
gem 'pg'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootsnap'

gem 'redis'
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector.git', branch: 'master'
gem 'airbrake'

gem 'puma', '~> 3.12.0'
gem 'aws-sdk'

# For pushing out updates after processing an event.
gem 'pusher'
gem 'lograge'

group :development, :test do
  gem 'envyable', require: 'envyable/rails-now'
  gem 'byebug'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  gem 'redis-namespace'
  gem 'spring'
end

group :test do
  gem 'rspec-rails', '~> 3.8'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'web-console', '~> 2.0'
end

gem "aws-sdk-secretsmanager", "~> 1.24"
