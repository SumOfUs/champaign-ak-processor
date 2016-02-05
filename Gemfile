source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.5'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'typhoeus'

# For interacting with the ActionKit API.
#gem 'actionkit_connector', '~> 0.3.0'
#gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector', branch: 'master'

gem 'actionkit_connector', path: '../actionkit_connector'
gem 'puma', '~> 2.15.3'

# For pushing out updates after processing an event.
gem 'pusher'


group :development, :test do
  gem 'byebug'
  gem 'envyable'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'rspec-rails', '~> 3.3'
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
end

