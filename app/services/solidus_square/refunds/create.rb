# frozen_string_literal: true

# When a merchant refunds a Square payment through the OMS,
# the app will process the refund through Square
# and the corresponding order, payment and refund information will be updated in the OMS.
module SolidusSquare
  module Refunds
    class Create < ::SolidusSquare::Base
      attr_reader :client, :idempotency_key, :payment_id, :amount, :currency

      def initialize(client:, idempotency_key:, payment_id:, amount:, currency:)
        @client = client
        @idempotency_key = idempotency_key
        @payment_id = payment_id
        @amount = amount
        @currency = currency
        super
      end

      def call
        # response has an id, we should probably save this reference (get paymen refund)
        # {
        #   "refund": {
        #     "id": "UNOE3kv2BZwqHlJ830RCt5YCuaB_xVteEWVFkXDvKN1ddidfJWipt8p9whmElKT5mZtJ7wZ",
        #     "status": "PENDING",
        #     "amount_money": {
        #       "amount": 100,
        #       "currency": "USD"
        #     },
        #     "payment_id": "UNOE3kv2BZwqHlJ830RCt5YCuaB",
        #     "created_at": "2018-10-17T20:41:55.520Z",
        #     "updated_at": "2018-10-17T20:41:55.520Z"
        #   }
        # }

        initiate_refund
      rescue ::Square::APIException => e
        # probably add tracking here
        raise e
      end

      def initiate_refund
        result = client.refunds.refund_payment(construct_refund)
        return [] if result.data.blank?

        data = JSON.parse result.data.to_json
        data['refund']
      end

      private

      def construct_refund
        {
          body: {
            idempotency_key: idempotency_key,
            amount_money: {
              amount: amount,
              currency: currency
            },
            payment_id: payment_id
          }
        }
      end
    end
  end
end
