# frozen_string_literal: true

SolidusSquare.configure do |config|
  config.square_environment = 'sandbox'
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_location_id = ENV['SQUARE_LOCATION_ID'] || 'LOCATION'
end
