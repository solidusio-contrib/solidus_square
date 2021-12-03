# frozen_string_literal: true

module SolidusSquare
  module Api
    class PaymentsController < BaseController
      def create
        order = ::Spree::Order.find_by!(number: params[:payment][:order_number])
        authorize! :update, order, order_token

        SolidusSquare::CreatePaymentService.call(
          source_id: params[:payment][:source_id],
          order: order,
          payment_method_id: params[:payment][:payment_method_id]
        )

        render json: {}, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
