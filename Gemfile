source 'https://rubygems.org'

ruby '2.3.0'
gem 'envyable', require: 'envyable/rails-now', group: [:test, :development]
gem 'rails', '4.2.5'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'redis'
gem 'actionkit_connector', github: 'SumOfUs/actionkit_connector', branch: 'update-user'

gem 'puma', '~> 2.15.3'
gem 'aws-sdk'

# For pushing out updates after processing an event.
gem 'pusher'
gem 'lograge'

group :development, :test do
  gem 'byebug'
  gem 'guard-rspec', require: false
  gem 'redis-namespace'
end

group :test do
  gem 'rspec-rails', '~> 3.3'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'web-console', '~> 2.0'
end

