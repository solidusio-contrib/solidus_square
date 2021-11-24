# frozen_string_literal: true

module SolidusSquare
  class CallbackActionsController < BaseController
    include Spree::Core::ControllerHelpers::Order
    helper 'solidus_square/checkout'

    before_action :load_order, only: [:square_checkout]

    def square_checkout
      authorize! :update, @order, order_token

      checkout_page_url = helpers.solidus_square_gateway.checkout(@order, redirect_url)[:checkout_page_url]

      respond_to do |format|
        format.html { redirect_to checkout_page_url }
      end
    end

    def complete_checkout
      @current_order = ::Spree::Order.create(user_id: spree_current_user&.id)
      cookies.signed[:guest_token] = @current_order.guest_token
      redirect_to preferred_redirect_url
    end

    private

    def order_token
      request.headers["X-Spree-Order-Token"] || params[:order_token]
    end

    def load_order
      @order = current_order
    end

    def redirect_url
      square_checkout_complete_url
    end

    def preferred_redirect_url
      ::SolidusSquare.config.square_payment_method.preferred_redirect_url
    end
  end
end
