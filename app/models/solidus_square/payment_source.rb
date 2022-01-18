# frozen_string_literal: true

require_dependency 'solidus_square'

module SolidusSquare
  class PaymentSource < SolidusSupport.payment_source_parent_class

    def can_void?(payment)
      return false unless payment.response_code

      result = payment.payment_method.gateway.get_payment(payment.response_code)
      status = result[:card_details][:status]

      !SolidusSquare::PaymentMethod::NOT_VOIDABLE_STATUSES.include?(status)
    end

    def captured?
      status == "CAPTURED"
    end
  end
end
