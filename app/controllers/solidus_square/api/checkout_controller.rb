# frozen_string_literal: true

module SolidusSquare
  module Api
    class CheckoutController < BaseController
      before_action :load_order, only: [:create]
      include Spree::Core::ControllerHelpers::Order

      helper 'solidus_square/checkout'

      def create
        authorize! :update, @order, order_token

        checkout_page_url = helpers.solidus_square_gateway.checkout(@order, redirect_url)[:checkout_page_url]

        respond_to do |format|
          format.json { render json: { checkout_page_url: checkout_page_url } }
        end
      end

      private

      def load_order
        @order = ::Spree::Order.find_by!(number: params[:id])
      end

      def redirect_url
        square_checkout_complete_url
      end
    end
  end
end
