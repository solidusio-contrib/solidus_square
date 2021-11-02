# frozen_string_literal: true

require 'spec_helper'

describe ::SolidusSquare::Customers::Create do
  subject(:service) do
    described_class.call({ client: client, spree_user: spree_user, spree_address: spree_address })
  end

  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:client) { instance_double(Square::Client, customers: customer_api) }

  context 'when customer already exists' do
    let(:customer_api) { instance_double(Square::CustomersApi, search_customers: api_response) }
    let(:api_response) do
      instance_double(Square::ApiResponse, success?: true, data: OpenStruct.new(customers: [{ 'id' => 111 }]))
    end

    it 'returns existing customer data' do
      expect(service['id']).to eq 111
    end
  end

  context 'when customer is new' do
    let(:customer_api) {
      instance_double(
        Square::CustomersApi,
        search_customers: search_api_response,
        create_customer: create_api_response
      )
    }
    let(:search_api_response) do
      instance_double(Square::ApiResponse, success?: true, data: OpenStruct.new(customers: []))
    end
    let(:create_api_response) do
      instance_double(Square::ApiResponse, success?: true, data: OpenStruct.new(customer: { 'id' => 111 }))
    end

    it 'returns new customer data' do
      expect(service['id']).to eq 111
    end

    context 'when server fails' do
      let(:errors) { [{ key: :value }] }

      context 'with search request' do
        let(:search_api_response) do
          instance_double(Square::ApiResponse, success?: false, errors: errors)
        end

        it 'raises an exception' do
          expect { service }.to raise_error(SolidusSquare::ServerError, errors.to_json)
        end
      end

      context 'with create request' do
        let(:create_api_response) do
          instance_double(Square::ApiResponse, success?: false, errors: errors)
        end

        it 'raises an exception' do
          expect { service }.to raise_error(SolidusSquare::ServerError, errors.to_json)
        end
      end
    end
  end
end
