# frozen_string_literal: true

require 'square'

module SolidusSquare
  class Gateway
    attr_reader :client, :location_id

    def initialize(options)
      @location_id = options[:location_id]
      @client = ::Square::Client.new(
        access_token: options[:access_token],
        environment: options[:environment]
      )
    end

    def capture(_amount, _response_code, options)
      payment = options[:originator]
      payment_source = payment.source
      square_payment_id = payment_source.square_payment_id
      response = capture_payment(square_payment_id)

      payment_source.update!(payment_source_constructor(response))

      ActiveMerchant::Billing::Response.new(true, 'Transaction captured', response, authorization: square_payment_id)
    end

    def create_customer(user, address)
      ::SolidusSquare::Customers::Create.call(client: client, spree_user: user, spree_address: address)
    end

    def checkout(order, redirect_url)
      ::SolidusSquare::Checkouts::Create.call(
        client: client,
        location_id: location_id,
        order: order,
        redirect_url: redirect_url
      )
    end

    def retrieve_order(order_id)
      ::SolidusSquare::Orders::Retrieve.call(
        client: client,
        order_id: order_id
      )
    end

    def get_payment(payment_id)
      ::SolidusSquare::Payments::Retrieve.call(
        client: client,
        payment_id: payment_id
      )
    end

    def create_payment(amount, source_id)
      ::SolidusSquare::Payments::Create.call(
        client: client,
        amount: amount,
        source_id: source_id
      )
    end

    def capture_payment(payment_id)
      ::SolidusSquare::Payments::Capture.call(
        client: client,
        payment_id: payment_id
      )
    end

    def payment_source_constructor(data)
      SolidusSquare::PaymentSourcePresenter.square_payload(data)
    end
  end
end
