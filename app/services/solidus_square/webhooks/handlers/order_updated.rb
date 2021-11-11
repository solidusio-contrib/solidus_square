# frozen_string_literal: true

module SolidusSquare
  module Webhooks
    module Handlers
      class OrderUpdated < Base
        def call
          return if not_completed?
          return unless order.payment?

          create_square_payment!

          order.next!
          order.complete!
        end

        private

        def order_info
          @order_info ||= square_payment_method.gateway.retrieve_order(square_order_id)
        end

        def square_order_id
          params[:data][:id]
        end

        def not_completed?
          params[:data][:object][:order_updated][:state] != "COMPLETED"
        end

        def order_number
          order_info[:reference_id]
        end

        def order
          @order ||= ::Spree::Order.find_by!(number: order_number)
        end

        def order_amount
          order_info[:total_money][:amount] / 100.0
        end

        def create_square_payment!
          order.payments.find_or_create_by!(response_code: square_order_id) do |payment|
            payment.amount = order_amount
            payment.source = ::SolidusSquare::PaymentSource.create!(token: square_order_id)
            payment.payment_method_id = square_payment_method.id
            payment.state = 'pending'
          end
        end
      end
    end
  end
end
