# frozen_string_literal: true

SolidusSquare.configure do |config|
  config.square_environment = 'sandbox'
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_location_id = ENV['SQUARE_LOCATION_ID'] || 'LOCATION'
end

module SquareHelpers
  def find_or_create_square_order_id_on_sandbox(order:, hosted_checkout: false)
    client = ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
    square_order = detect_order_by_order_number(client, order.number)
    return square_order if square_order.present?

    order_payload = order_payload(order)
    order_payload[:order][:metadata] = { hosted_checkout: "true" } if hosted_checkout
    client.orders.create_order(body: order_payload).data.order[:id]
  end

  def detect_order_by_order_number(client, order_number)
    order_ids_result = client.orders.search_orders(search_params(order_number))
    return if order_ids_result.data.nil?

    order_ids_result.data.order_entries.first[:order_id]
  end

  def order_payload(order)
    {
      idempotency_key: SecureRandom.uuid,
      order: {
        location_id: SolidusSquare.config.square_location_id,
        reference_id: order.number,
        customer_id: Base64.urlsafe_encode64(order.email),
        source: {
          name: "solidus_square_test_#{order.number}"
        },
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

  def search_params(order_number)
    {
      body: {
        location_ids: [SolidusSquare.config.square_location_id],
        limit: 1,
        return_entries: true,
        query: {
          filter: {
            source_filter: {
              source_names: ["solidus_square_test_#{order_number}"]
            }
          }
        }
      }
    }
  end

  def create_customer_id_on_sandbox
    client = ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
    client.customers.create_customer(body: {
      given_name: 'John',
      family_name: 'Doe',
      email_address: 'john.doe@gmail.com',
    }).data.customer[:id]
  end

  def create_authorized_square_payment_id_on_sandbox(source_id: nil)
    client = ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
    client.payments.create_payment(body: create_payment_payload(source_id: source_id)).data.payment[:id]
  end

  def create_and_capture_payment_on_sandbox
    client = ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )

    client.payments.complete_payment(payment_id: create_authorized_square_payment_id_on_sandbox).body.payment
  end

  def create_payment_payload(source_id: 'EXTERNAL')
    external_details = { type: "CHECK", source: "Food Delivery Service" }
    idempotency_key = rand(1_000_000_000_000_000).to_s
    amount_money = { amount: 123, currency: "USD" }
    {
      idempotency_key: idempotency_key,
      amount_money: amount_money,
      source_id: source_id,
      external_details: external_details,
      autocomplete: false
    }
  end

  def square_payment_response(amount: 100, status: "CAPTURED", order_id: 12)
    {
      id: 123,
      amount_money: {
        amount: amount
      },
      card_details: {
        status: status,
        card: {
          card_brand: "MASTERCARD",
          last_4: "9029", # rubocop:disable Naming/VariableNumber
          exp_month: 11,
          exp_year: 2022,
          card_type: "CREDIT"
        },
        avs_status: "AVS_ACCEPTED",
      },
      order_id: order_id,
      version: 3
    }
  end
end
