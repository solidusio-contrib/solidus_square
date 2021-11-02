# frozen_string_literal: true

SolidusSquare.configure do |config|
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_environment = ENV['SQUARE_ENVIRONMENT']
  config.square_location_id = ENV['SQUARE_LOCATION_ID']
end

Spree::Config.configure do |config|
  config.static_model_preferences.add(
    SolidusSquare::PaymentMethod,
    'square_credentials', {
      access_token: SolidusSquare.config.square_access_token,
      environment: SolidusSquare.config.square_environment
    }
  )
end
