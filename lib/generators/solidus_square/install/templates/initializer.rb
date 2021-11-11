# frozen_string_literal: true

SolidusSquare.configure do |config|
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_environment = ENV['SQUARE_ENVIRONMENT']
  config.square_location_id = ENV['SQUARE_LOCATION_ID']
  # config.square_payment_method = Spree::PaymentMethod.find(ENV['SQUARE_PAYMENT_METHOD_ID'])
end
