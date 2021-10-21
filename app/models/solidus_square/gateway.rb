# frozen_string_literal: true

require 'square'

module SolidusSquare
  class Gateway
    attr_accessor :options, :client

    def initialize(options)
      @options = options
      @client = ::Square::Client.new(
        access_token: options[:access_token],
        environment: options[:environment]
      )
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
      
      ActiveMerchant::Billing::Response.new(true, 'Transaction captured', result, authorization: result.id)
    rescue => e
      ActiveMerchant::Billing::Response.new(false, e.message)
    end

    def capture(_amount, _response_code, gateway_options)
      payment_method = gateway_options[:originator]
      location_id = payment_method.preferred_location_id
      order = gateway_options.order
      response = checkout(idempotency_key, location_id, order, redirect_url)
      result = response.body

      ActiveMerchant::Billing::Response.new(true, 'Transaction captured', result, authorization: result.id)
    rescue => e
      ActiveMerchant::Billing::Response.new(false, e.message)
    end
  end
end
