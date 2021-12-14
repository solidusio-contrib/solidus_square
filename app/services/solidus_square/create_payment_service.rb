# frozen_string_literal: true

module SolidusSquare
  class CreatePaymentService < Base
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

    attr_reader :source_id, :order, :payment_method_id

    def create_payment!
      ::Spree::PaymentCreate.new(order, payment_attributes).build.save!
    end

    def payment_attributes
      {
        source: ::SolidusSquare::PaymentSource.create!(nonce: source_id),
        payment_method_id: payment_method_id,
        amount: order.total
      }
    end

    def payment_method
      @payment_method ||= ::Spree::PaymentMethod.find(payment_method_id)
    end

    def gateway
      @gateway ||= payment_method.gateway
    end
  end
end
