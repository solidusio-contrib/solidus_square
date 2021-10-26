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
  end
end
