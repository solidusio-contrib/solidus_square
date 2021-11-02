# frozen_string_literal: true

module SolidusSquare
  module Webhooks
    module Handlers
      class OrderUpdated < Base
        def call
          return if not_completed?

          ::Spree::Payment.create!(payment_params) unless order.complete?
          order.update!(state: "complete")
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

        def payment_params
          {
            amount: order_info[:total_money][:amount],
            order: order,
            source: ::SolidusSquare::PaymentSource.create!(token: square_order_id),
            payment_method_id: square_payment_method.id
          }
        end
      end
    end
  end
end
