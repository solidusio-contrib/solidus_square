# frozen_string_literal: true

module SolidusSquare
  module Cards
    class Create < ::SolidusSquare::Base
      attr_reader :client, :source_id, :bill_address, :customer_id

      def initialize(client:, source_id:, bill_address:, customer_id:)
        @client = client
        @bill_address = bill_address
        @customer_id = customer_id
        @source_id = source_id

        super
      end

      def call
        create_card
      end

      private

      def create_card
        handle_square_result(client.cards.create_card(body: construct_card)) do |result|
          result.data&.card
        end
      end

      def construct_card
        {
          idempotency_key: idempotency_key,
          source_id: source_id,
          card: {
            cardholder_name: bill_address.name,
            customer_id: customer_id,
          }
        }
      end
    end
  end
end
