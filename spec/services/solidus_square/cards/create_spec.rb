# frozen_string_literal: true

require 'spec_helper'

describe ::SolidusSquare::Cards::Create do
  subject(:service) do
    described_class.call({ client: client, source_id: source_id, bill_address: bill_address, customer_id: customer_id })
  end

  let(:source_id) { create_authorized_square_payment_id_on_sandbox(source_id: 'cnon:card-nonce-ok') }
  let(:customer_id) { create_customer_id_on_sandbox }
  let(:spree_user) { create(:user_with_addresses) }
  let(:bill_address) { spree_user.addresses.first }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  it 'Creates the Card on square', :vcr do
    expect(service).to match hash_including(
      :id, :card_brand, :customer_id, enabled: true, cardholder_name: bill_address.name
    )
  end
end
