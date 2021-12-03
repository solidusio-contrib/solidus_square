# frozen_string_literal: true

module SolidusSquare
  class CreatePaymentService < Base
    attr_reader :source_id, :order, :payment_method_id

    def initialize(source_id:, order:, payment_method_id:)
      @source_id = source_id
      @order = order
      @payment_method_id = payment_method_id

      super()
    end

    def call
      order.next! if order.delivery?
      create_payment!
    end

    private

    def square_order_id
      square_payment_response[:order_id]
    end

    def square_payment_response
      @square_payment_response ||= gateway.create_payment(order.total, source_id)
    end

    def create_payment!
      order.payments.find_or_create_by!(response_code: square_order_id) do |payment|
        payment.amount = payment_amount
        payment.source = ::SolidusSquare::PaymentSource.create!(construct_payment_source)
        payment.payment_method_id = payment_method_id
        payment.state = 'pending'
      end
    end

    def payment_method
      @payment_method ||= ::Spree::PaymentMethod.find(payment_method_id)
    end

    def gateway
      @gateway ||= payment_method.gateway
    end

    def payment_amount
      square_payment_response[:amount_money][:amount] / 100.0
    end

    def construct_payment_source
      ::SolidusSquare::PaymentSourcePresenter.square_payload(square_payment_response).merge(
        payment_method_id: payment_method_id
      )
    end
  end
end
