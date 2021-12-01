# frozen_string_literal: true

module SolidusSquare
  class PaymentSyncService < Base
    attr_reader :params

    def initialize(params)
      @params = params

      super()
    end

    def call
      return unless hosted_checkout?

      create_square_payment!

      update_payment_source!
      payment.complete! if payment_source.captured? && !payment.completed?

      complete_order!
    end

    private

    def complete_order!
      return unless order.payment?

      order.next!
      order.complete!
    end

    def construct_payment_source
      ::SolidusSquare::PaymentSourcePresenter.square_payload(params)
    end

    def update_payment_source!
      payment_source.update!(construct_payment_source) if new_data?
    end

    def square_order_id
      payment_data[:order_id]
    end

    def payment_data
      params[:data][:object][:payment]
    end

    def order_amount
      payment_data[:amount_money][:amount] / 100.0
    end

    def new_data?
      payment_source.version.to_i <= version
    end

    def version
      payment_data[:version]
    end

    def hosted_checkout?
      order_info.dig(:metadata, :hosted_checkout) == "true"
    end

    # Spree Order information

    def order
      @order ||= ::Spree::Order.find_by!(number: order_number)
    end

    def order_number
      order_info[:reference_id]
    end
    # Spree Payment information

    def payment
      @payment ||= order.payments.find_by!(response_code: square_order_id)
    end

    def payment_source
      @payment_source ||= ::SolidusSquare::PaymentSource.find_by!(token: square_order_id)
    end

    def create_square_payment!
      order.payments.find_or_create_by!(response_code: square_order_id) do |payment|
        payment.amount = order_amount
        payment.source = ::SolidusSquare::PaymentSource.create!(token: square_order_id, version: version)
        payment.payment_method_id = square_payment_method.id
        payment.state = 'pending'
      end
    end
    # Square Order information

    def order_info
      @order_info ||= square_payment_method.gateway.retrieve_order(square_order_id)
    end

    def square_payment_method
      SolidusSquare.config.square_payment_method
    end
  end
end
