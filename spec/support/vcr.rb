# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
end
