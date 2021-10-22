# frozen_string_literal: true
require 'square'

module SolidusSquare
  class Gateway
    include Rails.application.routes.url_helpers

    attr_reader :client, :location_id

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


      ActiveMerchant::Billing::Response.new(true, 'Transaction captured', result, authorization: result.id)
    rescue => e
      ActiveMerchant::Billing::Response.new(false, e.message)
    end
  end
end
