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

    def authorize(amount, payment_source, gateway_options)
      create_payment_on_square(amount, payment_source, gateway_options)
    end

    def capture(_amount, response_code, options)
      payment_source = options[:originator].source
      response = capture_payment(response_code)

      payment_source.update!(payment_source_constructor(response))

      ActiveMerchant::Billing::Response.new(true, 'Transaction captured', response, authorization: response_code)
    end

    def credit(amount, response_code, _options)
      response = refund_payment(amount, response_code)

      ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{amount}", response,
        authorization: response_code)
    end

    def void(response_code, options)
      payment_source = options[:originator].source
      response = cancel_payment(response_code)
      payment_source.update!(status: response[:status])

      ActiveMerchant::Billing::Response.new(true, 'Transaction voided', response, authorization: response[:id])
    end

    def create_customer(user, address)
      ::SolidusSquare::Customers::Create.call(client: client, spree_user: user, spree_address: address)
    end

    def purchase(amount, payment_source, gateway_options)
      create_payment_on_square(amount, payment_source, gateway_options)
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

    def create_payment(amount, source_id, auto_capture, customer_id)
      ::SolidusSquare::Payments::Create.call(
        client: client,
        amount: amount,
        source_id: source_id,
        auto_capture: auto_capture,
        customer_id: customer_id
      )
    end

    def capture_payment(payment_id)
      ::SolidusSquare::Payments::Capture.call(
        client: client,
        payment_id: payment_id
      )
    end

    def cancel_payment(payment_id)
      ::SolidusSquare::Payments::Void.call(
        client: client,
        payment_id: payment_id
      )
    end

    def refund_payment(amount, payment_id)
      ::SolidusSquare::Refunds::Create.call(
        client: client,
        amount: amount,
        payment_id: payment_id
      )
    end

    def payment_source_constructor(data)
      SolidusSquare::PaymentSourcePresenter.square_payload(data)
    end

    def create_profile(payment)
      user = payment.order.user
      return if user.nil?
      return if user&.square_customer&.square_customer_ref

      square_customer = SolidusSquare::Customers::Create.call(
        client: client, spree_user: payment.order.user, spree_address: payment.order.bill_address
      )

      payment.source.create_customer(
        square_customer_ref: square_customer[:id],
        user: payment.order.user
      )
    end

    private

    def create_card(source_id, bill_address, customer_id)
      SolidusSquare::Cards::Create.call(
        client: client, source_id: source_id, bill_address: bill_address, customer_id: customer_id
      )
    end

    def create_payment_on_square(amount, payment_source, gateway_options)
      payment = gateway_options[:originator]
      order = payment.order
      auto_capture = payment.payment_method.auto_capture

      if payment_source.token
        source_id = payment_source.token
        customer_id = square_customer_ref(order)
        square_payment = create_payment(amount, source_id, auto_capture, customer_id)
      else
        source_id = payment_source.nonce
        square_payment = create_payment(amount, source_id, auto_capture)

        if order.user.present?
          card = create_card(square_payment[:id], order.bill_address, square_customer_ref(order))
          payment_source.update!(token: card[:id])
        end
        payment_source.update!(payment_source_constructor(square_payment))
      end

      payment.response_code = square_payment[:id]

      ActiveMerchant::Billing::Response.new(true, 'Transaction approved', square_payment,
        authorization: square_payment[:id])
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
    end

    def square_customer_ref(order)
      order.user&.square_customer&.square_customer_ref
    end
  end
end
