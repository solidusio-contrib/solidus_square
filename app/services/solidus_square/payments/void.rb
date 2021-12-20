# frozen_string_literal: true

module SolidusSquare
  module Payments
    class Void < ::SolidusSquare::Base
      def initialize(client:, payment_id:)
        @client = client
        @payment_id = payment_id

        super
      end

      def call
        cancel_payment
      end

      private

      attr_reader :client, :payment_id

      def cancel_payment
        handle_square_result(client.payments.cancel_payment(payment_id: payment_id)) do |result|
          result.body&.payment
        end
      end
    end
  end
end
