# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::PaymentMethod, type: :model do
  it { is_expected.to delegate_method(:create_profile).to(:gateway) }

  describe '#payment_profiles_supported?' do
    it 'return true' do
      expect(described_class.new).to be_payment_profiles_supported
    end
  end

  describe '#try_void' do
    let(:payment) { create(:payment) }

    context 'when the payment cannot be voided' do
      subject(:try_void) { described_instance.try_void(payment) }

      let(:described_instance) { described_class.new }
      let(:response) { ActiveMerchant::Billing::Response.new(true, 'Transaction voided', {}, authorization: '123') }

      before do
        allow(payment.source).to receive(:can_void?).and_return(true)
        allow(described_instance.gateway).to receive(:void).and_return(response)
      end

      it 'calls void on the gateway' do
        try_void

        expect(described_instance.gateway).to have_received(:void).with(
          payment.response_code,
          originator: payment
        )
      end
    end
  end
end
