# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Gateway do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:options) { { access_token: 'abcde', environment: 'sandbox', location_id: 'location' } }
  let(:gateway) { described_class.new(options) }
  let(:payment) { create(:payment, response_code: nil) }
  let(:payment_source) { create(:square_payment_source, nonce: 'nonce') }
  let(:square_response) { square_payment_response }
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
  end

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

    let(:gateway_options) { { originator: payment } }

    let(:capture_params) do
      {
        client: gateway.client,
        payment_id: payment.response_code
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

  describe "#refund_payment" do
    subject(:refund_payment) { gateway.refund_payment(1234, "payment_id") }

    before do
      allow(SolidusSquare::Refunds::Create).to receive(:call)
      refund_payment
    end

    it "calls the SolidusSquare::Refunds::Create service" do
      expect(SolidusSquare::Refunds::Create).to have_received(:call).with(client: gateway.client, amount: 1234,
        payment_id: "payment_id")
    end
  end

  describe "#credit" do
    subject(:credit) { gateway.credit(123, "response_code", gateway_options) }

    let(:gateway_options) { { originator: OpenStruct.new(payment: payment) } }
    let(:square_response) do
      OpenStruct.new(body: OpenStruct.new(refund: {} ))
    end
    let(:credit_params) do
      {
        client: gateway.client,
        amount: 123,
        payment_id: payment.response_code
      }
    end

    before do
      allow(gateway).to receive(:refund_payment).and_return(square_response)
      credit
    end

    it "returns an ActiveMerchant::Billing::Response " do
      expect(credit).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it "returns a successfull response" do
      expect(credit).to be_success
    end
  end

  describe '#cancel_payment' do
    subject(:cancel_payment) { gateway.cancel_payment(1234) }

    before do
      allow(SolidusSquare::Payments::Void).to receive(:call)
      cancel_payment
    end

    it "calls the SolidusSquare::Payments::Void service" do
      expect(SolidusSquare::Payments::Void).to have_received(:call).with(client: gateway.client, payment_id: 1234)
    end
  end

  describe '#void' do
    subject(:void) { gateway.void("response_code", gateway_options) }

    let(:gateway_options) { { originator: payment } }
    let(:voided_square_response) do
      {
        status: "CANCELED"
      }
    end

    before do
      allow(gateway).to receive(:cancel_payment).and_return(voided_square_response)
      void
    end

    it "updates the payment source status" do
      expect(payment_source.status).to eq('CANCELED')
    end

    it "returns an ActiveMerchant::Billing::Response " do
      expect(void).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it "returns a successfull response" do
      expect(void).to be_success
    end
  end

  RSpec.shared_examples "#create_payment_on_square" do
    context "when valid" do
      before do
        allow(gateway).to receive(:create_payment).with(123, 'nonce', nil).and_return(square_response)
      end

      it "updates the payment source attributes" do
        method
        expect(payment_source).to have_attributes(expected_attributes)
      end

      it "returns an ActiveMerchant::Billing::Response " do
        expect(method).to be_an_instance_of(ActiveMerchant::Billing::Response)
      end

      it "returns a successfull response" do
        expect(method).to be_success
      end

      it "updates the payment response code" do
        method
        expect(payment.response_code).to eq '123'
      end
    end

    context "when not valid" do
      before do
        allow(gateway).to receive(:create_payment).with(123, 'nonce', nil).and_raise(StandardError, "test error")
      end

      it "returns an ActiveMerchant::Billing::Response with the correct message" do
        expect(method).to be_an_instance_of(ActiveMerchant::Billing::Response)
        expect(method.message).to eq 'test error'
      end
    end
  end

  describe '#autorize' do
    it_behaves_like "#create_payment_on_square" do
      let(:method) {  gateway.authorize(123, payment_source, { originator: payment }) }
    end
  end

  describe "#purchase" do
    it_behaves_like "#create_payment_on_square" do
      let(:method) {  gateway.purchase(123, payment_source, { originator: payment }) }
    end
  end
end
