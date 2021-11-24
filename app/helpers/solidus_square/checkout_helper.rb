# frozen_string_literal: true

module SolidusSquare
  module CheckoutHelper
    def solidus_square_gateway
      SolidusSquare::Gateway.new(
        access_token: SolidusSquare.config.square_access_token,
        environment: SolidusSquare.config.square_environment,
        location_id: SolidusSquare.config.square_location_id
      )
    end
  end
end
