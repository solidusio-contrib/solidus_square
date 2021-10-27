# frozen_string_literal: true

# A customer profile will be created in Square whenever an order is completed.
# The payment method used to pay for the order will be tied to the customer's profile in Square,
# so that it can be used to charge the customer at a later stage (e.g., for subscriptions).
module SolidusSquare
  module Customers
    class Create < ::SolidusSquare::Base
      attr_reader :client, :spree_user, :spree_address

      def initialize(client:, spree_user:, spree_address:)
        @client = client
        @spree_user = spree_user
        @spree_address = spree_address
        super
      end

      def call
        # search for existing customer first
        # otherwise, create new customer
        customer = search_customer
        customer.presence || create_customer
      end

      def create_customer
        handle_square_result(client.customers.create_customer(construct_customer)) do |result|
          result.data&.customer
        end
      end

      def search_customer
        handle_square_result(client.customers.search_customers(construct_search_query)) do |result|
          result.data&.customers&.first
        end
      end

      private

      # rubocop:disable Naming/VariableNumber
      def construct_customer
        name = spree_address.name.split(' ')
        {
          body: {
            given_name: name.first,
            family_name: name.last,
            email_address: spree_user.email,
            address: {
              address_line_1: spree_address.address1,
              address_line_2: spree_address.address2,
              locality: spree_address.city,
              postal_code: spree_address.zipcode,
              country: spree_address.country.iso
            },
            phone_number: spree_address.phone,
            reference_id: spree_user.id.to_s
          }
        }
      end
      # rubocop:enable Naming/VariableNumber

      def construct_search_query
        {
          body: {
            limit: 1,
            query: {
              filter: {
                email_address: {
                  fuzzy: spree_user.email
                },
              }
            }
          }
        }
      end
    end
  end
end
