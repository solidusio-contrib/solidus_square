# frozen_string_literal: true

module SolidusSquare
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    preference :access_token, :string
    preference :environment, :string
    preference :location_id, :string
    preference :app_id, :string
    preference :redirect_url, :string

    NOT_VOIDABLE_STATUSES = %w[CAPTURED VOIDED].freeze

    delegate :create_profile, to: :gateway

    def gateway_class
      ::SolidusSquare::Gateway
    end

    def payment_source_class
      ::SolidusSquare::PaymentSource
    end

    def payment_profiles_supported?
      true
    end

    def partial_name
      "square"
    end

    def try_void(payment)
      return false unless payment.source.can_void?(payment)

      gateway.void(payment.response_code, originator: payment)
    end
  end
end
