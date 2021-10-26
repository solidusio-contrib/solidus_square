# frozen_string_literal: true

# The platform will be integrated with Square's Checkout API.
# When a customer proceeds to checkout from a store that uses Square as its PSP,
# the customer will be redirected to Square's hosted checkout.
# The customer will enter their payment information and process payment in Square's UI.
# Upon successful payment, the customer will be redirected back to the merchant's site.
# The corresponding customer, order and payment information will be updated in the OMS.
module SolidusSquare
  module Checkouts
    class Create < ::SolidusSquare::Base
      attr_reader :client, :location_id, :order, :redirect_url

      def initialize(client:, location_id:, order:, redirect_url:)
        @client = client
        @location_id = location_id
        @order = order
        @redirect_url = redirect_url
        super
      end

      def call
        create_checkout
      end

      private

      def create_checkout
        result = client.checkout.create_checkout(construct_checkout)
        result.data&.checkout
      end

      def construct_checkout
        {
          location_id: location_id,
          body: {
            idempotency_key: idempotency_key,
            order: {
              order: {
                location_id: location_id,
                reference_id: order.number,
                customer_id: order.user_id,
                line_items: [{
                  name: 'Order total',
                  quantity: '1',
                  base_price_money: {
                    amount: Money.from_amount(order.total).fractional,
                    currency: order.currency
                  }
                }],
              }
            },
            pre_populate_buyer_email: order.email,
            redirect_url: redirect_url
          }
        }
      end
    end
  end
end
