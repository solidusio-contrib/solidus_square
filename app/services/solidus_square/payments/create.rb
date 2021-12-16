# frozen_string_literal: true

module SolidusSquare
  module Payments
    class Create < ::SolidusSquare::Base
      def initialize(client:, source_id:, amount:)
        @client = client
        @source_id = source_id
        @amount = amount

        super
      end

      def call
        create_payment
      end

      private

      attr_reader :client, :source_id, :amount

      def create_payment
        handle_square_result(client.payments.create_payment(body: payment_payload)) do |result|
          result.body&.payment
        end
      end

      def payment_payload
        {
          idempotency_key: idempotency_key,
          source_id: source_id,
          amount_money: {
            amount: amount,
            currency: "USD"
          },
          autocomplete: false
        }
      end
    end
  end
end
