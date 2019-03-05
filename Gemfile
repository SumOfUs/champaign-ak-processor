source 'https://rubygems.org'

ruby '2.4.1'
gem 'rails', '5.2'
gem 'pg'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'redis'
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector.git', branch: 'master'
gem 'airbrake'

gem 'puma', '~> 2.15.3'
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
end

group :test do
  gem 'rspec-rails'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'web-console', '~> 2.0'
end
