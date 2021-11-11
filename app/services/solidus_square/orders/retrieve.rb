# frozen_string_literal: true

module SolidusSquare
  module Orders
    class Retrieve < ::SolidusSquare::Base
      attr_reader :client, :order_id

      def initialize(client:, order_id:)
        @client = client
        @order_id = order_id
        super
      end

      def call
        retrieve_order
      end

      private

      def retrieve_order
        handle_square_result(client.orders.retrieve_order(order_id: order_id)) do |result|
          result.body&.order
        end
      end
    end
  end
end
