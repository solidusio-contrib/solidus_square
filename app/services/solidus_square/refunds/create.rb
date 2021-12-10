# frozen_string_literal: true

module SolidusSquare
  module Refunds
    class Create < ::SolidusSquare::Base
      def initialize(client:, amount:, payment_id:)
        @client = client
        @amount = amount
        @payment_id = payment_id

        super
      end

      def call
        refund_payment
      end

      private

      attr_reader :client, :amount, :payment_id

      def refund_payment
        handle_square_result(client.refunds.refund_payment(body: refund_payload)) do |result|
          result.body&.refund
        end
      end

      def refund_payload
        {
          payment_id: payment_id,
          amount_money: amount_money,
          idempotency_key: idempotency_key
        }
      end

      def amount_money
        {
          amount: amount,
          currency: "USD"
        }
      end
    end
  end
end
