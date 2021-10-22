module SolidusSquare
  class CallbacksController < BaseController
    def order_complete
      order.next unless order.state == "confirm"

      respond_to do |format|
        format.html { redirect_to checkout_state_path(order.state) }
        format.json { render json: { redirect_url: checkout_state_url(order.state) } }
      end
    end

    private

    def order
      @order ||= Spree::Order.find_by(number: order_number)
    end

    def order_number
      params [:referenceId]
    end
  end
end
