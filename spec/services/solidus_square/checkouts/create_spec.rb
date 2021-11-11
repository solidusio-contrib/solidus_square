# frozen_string_literal: true

require 'spec_helper'

describe ::SolidusSquare::Checkouts::Create do
  subject(:service) do
    described_class.call(
      client: client,
      location_id: 'location1',
      order: spree_order,
      redirect_url: redirect_url
    )
  end

  let(:payment_method) { create(:square_payment_method) }
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:spree_order) { create(:order_with_line_items, user: spree_user, shipping_address: spree_address) }
  let(:redirect_url) { 'https://shop.com/process' }
  let(:client) { instance_double(Square::Client, checkout: checkout_api) }
  let(:checkout_api) { instance_double(Square::CheckoutApi, create_checkout: checkout_response) }
  let(:checkout_response) do
    instance_double(Square::ApiResponse, success?: true, data: OpenStruct.new(checkout: { 'id' => 111 }))
  end

  before do
    allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
  end

  context "with a successfull response" do
    it 'returns checkout data' do
      expect(service['id']).to eq 111
    end

    it "makes a request with the correct data" do
      service
      expect(checkout_api).to have_received(:create_checkout)
        .with(hash_including(
          body: hash_including(
            order: hash_including(
              order: hash_including(
                customer_id: Digest::MD5.hexdigest(spree_order.email)
              )
            )
          )
        ))
    end
  end

  context 'when the server fails with an error' do
    let(:error_hash) { [{ key: :value }] }
    let(:checkout_response) do
      instance_double(Square::ApiResponse, success?: false, errors: error_hash)
    end

    it 'raise a server exception' do
      expect { service }.to raise_error(SolidusSquare::ServerError, error_hash.to_json)
    end
  end
end
