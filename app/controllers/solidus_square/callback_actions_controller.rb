# frozen_string_literal: true

module SolidusSquare
  class CallbackActionsController < SolidusSquare::BaseController
    def square_checkout
      checkout_page_url = SolidusSquare::Gateway.new(
        access_token: SolidusSquare.config.square_access_token,
        environment: SolidusSquare.config.square_environment,
        location_id: SolidusSquare.config.square_location_id
      ).checkout(order, redirect_url)[:checkout_page_url]

      respond_to do |format|
        format.html { redirect_to checkout_page_url }
        format.json { render json: { redirect_url: checkout_page_url } }
      end
    end

    private

    def order
      @order ||= Spree::Order.find_by(number: params[:order_number])
    end

    def redirect_url
      ::SolidusSquare::PaymentMethod.active.first&.preferred_redirect_url
    end
  end
end
