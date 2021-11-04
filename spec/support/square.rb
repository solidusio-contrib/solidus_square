# frozen_string_literal: true

SolidusSquare.configure do |config|
  config.square_environment = 'sandbox'
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_location_id = ENV['SQUARE_LOCATION_ID'] || 'LOCATION'
end

module SquareHelpers
  def find_or_create_square_order_id_on_sandbox(order)
    result = client.orders.search_orders(search_params)
    return result.data.order_entries.first[:order_id] if result.data.present?

    client.orders.create_order(body: order_payload(order)).data.order[:id]
  end

  def order_payload(order)
    {
      idempotency_key: SecureRandom.uuid,
      order: {
        location_id: SolidusSquare.config.square_location_id,
        reference_id: order.number,
        customer_id: Base64.urlsafe_encode64(order.email),
        line_items: [{
          name: 'Order total',
          quantity: '1',
          base_price_money: {
            amount: Money.from_amount(order.total).fractional,
            currency: order.currency
          }
        }],
      }
    }
  end

  def search_params
    {
      body: {
        location_ids: [SolidusSquare.config.square_location_id],
        limit: 1,
        return_entries: true,
        query: {
          filter: {}
        }
      }
    }
  end
end
