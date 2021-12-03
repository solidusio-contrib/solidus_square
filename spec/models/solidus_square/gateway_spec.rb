# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Gateway do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:options) { { access_token: 'abcde', environment: 'sandbox', location_id: 'location' } }
  let(:described_instance) { described_class.new(options) }

  describe '#initialize' do
    it 'initialize options and client params' do
      expect(described_instance.location_id).to eq options[:location_id]
      expect(described_instance.client).to be_an_instance_of(::Square::Client)
    end
  end

  describe '#capture_payment' do
    subject(:capture_payment) { described_instance.capture_payment(12_345) }

    before do
      allow(SolidusSquare::Payments::Capture).to receive(:call)
      capture_payment
    end

    it "calls the SolidusSquare::Payments::Capture service" do
      expect(SolidusSquare::Payments::Capture).to have_received(:call).with(client: gateway.client, payment_id: 12_345)
    end
  end

  describe '#create_customer' do
    before do
      allow(::SolidusSquare::Customers::Create).to receive(:call)
    end

    it 'call SolidusSquare Customer Create class' do
      described_instance.create_customer(spree_user, spree_address)

      expect(::SolidusSquare::Customers::Create).to have_received(:call).with(
        client: described_instance.client,
        spree_user: spree_user,
        spree_address: spree_address
      )
    end
  end
end
