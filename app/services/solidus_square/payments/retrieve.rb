# frozen_string_literal: true

module SolidusSquare
  module Payments
    class Retrieve < ::SolidusSquare::Base
      attr_reader :client, :payment_id

      def initialize(client:, payment_id:)
        @client = client
        @payment_id = payment_id
        super
      end

      def call
        retrieve_payment
      end

      private

      def retrieve_payment
        handle_square_result(client.payments.get_payment(payment_id: payment_id)) do |result|
          result.body&.payment
        end
      end
    end
  end
end
