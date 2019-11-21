require 'webmock/rspec'
require 'vcr'
require_relative '../lib/ak/client'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<AK_USERNAME>") { ENV['AK_USERNAME'] }
  config.filter_sensitive_data("<AK_PASSWORD>") { ENV['AK_PASSWORD'] }
  config.filter_sensitive_data("<SP_API_KEY>") {ENV['SHARE_PROGRESS_API_KEY']}
  config.filter_sensitive_data("<CHAMPAIGN_API_KEY>") { ENV['CHAMPAIGN_API_KEY'] }

  # Removes all private data (Basic Auth, Set-Cookie headers...)
  config.before_record do |i|
    i.response.headers.delete('Set-Cookie')
    i.request.headers.delete('Authorization')
    u = URI.parse(i.request.uri)
    i.request.uri.sub!(/:\/\/.*#{Regexp.escape(u.host)}/, "://#{u.host}" )
  end

end

RSpec.configure do |config|
  config.include Ak::Client

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end

