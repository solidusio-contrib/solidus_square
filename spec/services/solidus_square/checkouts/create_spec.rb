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

  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:spree_order) { create(:order_with_line_items, user: spree_user, shipping_address: spree_address) }
  let(:redirect_url) { 'https://shop.com/process' }
  let(:client) { instance_double(Square::Client, checkout: checkout_api) }
  let(:checkout_api) { instance_double(Square::CheckoutApi, create_checkout: checkout_response) }
  let(:checkout_response) { instance_double(Square::ApiResponse, data: OpenStruct.new(checkout: { 'id' => 111 })) }

  it 'returns checkout data' do
    expect(service['id']).to eq 111
  end
end
