# frozen_string_literal: true

Spree::Config.configure do |config|
  config.static_model_preferences.add(
    SolidusSquare::PaymentMethod,
    'square_credentials', {
      access_token: ENV['SQUARE_ACCESS_TOKEN'],
      environment: ENV['SQUARE_ENVIRONMENT'],
    }
  )
end
