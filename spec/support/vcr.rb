# frozen_string_literal: true

require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  config.filter_sensitive_data('<BEARER_TOKEN>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end

  config.filter_sensitive_data('LOCATION_ID') do |interaction|
    interaction.request.body.match(SolidusSquare.config.square_location_id)
  end

  config.before_record do |interaction|
    interaction.request.uri.sub!(SolidusSquare.config.square_location_id, 'LOCATION_ID')
  end

  config.before_playback do |interaction|
    interaction.request.uri.sub!('LOCATION_ID', SolidusSquare.config.square_location_id)
  end

  # Let's you set default VCR record mode with VCR_RECORDE_MODE=all for re-recording
  # episodes. :once is VCR default
  record_mode = ENV.fetch('VCR_RECORD_MODE', :once).to_sym
  config.default_cassette_options = { record: record_mode }
end
