# frozen_string_literal: true

module SolidusSquare
  class CallbackActionsController < SolidusSquare::BaseController
    include Spree::Core::ControllerHelpers::Order

    helper 'spree/orders'

    def square_checkout
      checkout_page_url = SolidusSquare::Gateway.new(
        access_token: SolidusSquare.config.square_access_token,
        environment: SolidusSquare.config.square_environment,
        location_id: SolidusSquare.config.square_location_id
      ).checkout(order, redirect_url)[:checkout_page_url]

      respond_to do |format|
        format.html { redirect_to checkout_page_url }
      end
    end

    def complete_checkout
      @current_order = ::Spree::Order.create(user_id: current_order.user_id)
      cookies.signed[:guest_token] = current_order.guest_token
      redirect_to preferred_redirect_url
    end

    private

    def order
      @order ||= current_order
    end

    def redirect_url
      complete_checkout_url
    end

    def preferred_redirect_url
      ::SolidusSquare.config.square_payment_method.preferred_redirect_url
    end
  end
end
