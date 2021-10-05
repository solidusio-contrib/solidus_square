# frozen_string_literal: true

require 'square'

# Gateway class to call Square API
module SolidusSquare
  class Gateway
    attr_accessor :options, :client

    def initialize(options)
      # options: payment_method.preferences.to_hash
      @options = options
      @client = ::Square::Client.new(
        access_token: options[:access_token],
        environment: options[:environment]
      )
    end

    def create_customer(user, address)
      ::SolidusSquare::Customers::Create.call(client: client, spree_user: user, spree_address: address)
    end

    def refund
      # call refund service
    end

    def checkout
      # call checkout service
    end
  end
end
