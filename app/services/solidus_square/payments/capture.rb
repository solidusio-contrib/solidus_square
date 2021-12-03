# frozen_string_literal: true

module SolidusSquare
  module Payments
    class Capture < ::SolidusSquare::Base
      def initialize(client:, payment_id:)
        @client = client
        @payment_id = payment_id

        super
      end

      def call
        complete_payment
      end

      private

      attr_reader :client, :payment_id

      def complete_payment
        handle_square_result(client.payments.complete_payment(payment_id: payment_id)) do |result|
          result.body&.payment
        end
      end
    end
  end
end
