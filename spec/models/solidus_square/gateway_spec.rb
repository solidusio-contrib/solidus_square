# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Gateway do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:options) { { access_token: 'abcde', environment: 'sandbox', location_id: 'location' } }
  let(:gateway) { described_class.new(options) }

  describe '#initialize' do
    it 'initialize options and client params' do
      expect(gateway.location_id).to eq options[:location_id]
      expect(gateway.client).to be_an_instance_of(::Square::Client)
    end
  end

  describe '#capture_payment' do
    subject(:capture_payment) { gateway.capture_payment(12_345) }

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
      gateway.create_customer(spree_user, spree_address)

      expect(::SolidusSquare::Customers::Create).to have_received(:call).with(
        client: gateway.client,
        spree_user: spree_user,
        spree_address: spree_address
      )
    end
  end

  describe "#capture" do
    subject(:capture) { gateway.capture(nil, nil, gateway_options) }

    let(:payment) { create(:payment) }
    let(:payment_source) { create(:square_payment_source) }
    let(:gateway_options) { { originator: payment } }
    let(:square_response) { square_payment_response }
    let(:capture_params) do
      {
        client: gateway.client,
        payment_id: payment_source.square_payment_id
      }
    end
    let(:expected_attributes) do
      {
        version: 3,
        avs_status: "AVS_ACCEPTED",
        expiration_date: "11/2022",
        last_digits: "9029",
        card_brand: "MASTERCARD",
        card_type: "CREDIT",
        status: "CAPTURED"
      }
    end

    before do
      payment.source = payment_source
      allow(gateway).to receive(:capture_payment).and_return(square_response)
      capture
    end

    it "returns an ActiveMerchant::Billing::Response " do
      expect(capture).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it "updates the payment_source" do
      expect(payment_source).to have_attributes(expected_attributes)
    end
  end
end
