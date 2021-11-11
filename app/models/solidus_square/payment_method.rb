# frozen_string_literal: true

module SolidusSquare
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    preference :access_token, :string
    preference :environment, :string
    preference :location_id, :string
    preference :redirect_url, :string

    def gateway_class
      ::SolidusSquare::Gateway
    end

    def payment_source_class
      ::SolidusSquare::PaymentSource
    end

    def partial_name
      "square"
    end
  end
end
