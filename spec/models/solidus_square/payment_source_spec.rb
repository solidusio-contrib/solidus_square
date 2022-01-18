require 'spec_helper'

RSpec.describe SolidusSquare::PaymentSource, type: :model do
  let(:payment_source) { described_class.new(token: "12345", status: status) }
  let(:status) { "CAPTURED" }
  let(:payment_method) { create(:square_payment_method) }
  let(:payment) { instance_double(Spree::Payment) }
  let(:gateway) { instance_double(SolidusSquare::Gateway) }

  it { is_expected.to belong_to(:customer).class_name('SolidusSquare::Customer').optional }

  describe "#can_void?" do
    subject(:can_void?) { payment_source.can_void?(payment) }

    before do
      allow(payment).to receive(:payment_method).and_return(payment_method)
      allow(payment).to receive(:response_code).and_return("12345")
      allow(payment_method).to receive(:gateway).and_return(gateway)
      allow(gateway).to receive(:get_payment).and_return({ card_details: { status: status } })
    end

    context "when payment is captured" do
      it { expect(can_void?).to be_falsy }
    end

    context "when payment is voided" do
      let(:status) { "VOIDED" }

      it { expect(can_void?).to be_falsy }
    end

    context "when payment is not captured yet" do
      let(:status) { "AUTHORIZED" }

      it { expect(can_void?).to be_truthy }
    end
  end

  describe "#captured?" do
    context "when status is captured" do
      it { expect(payment_source).to be_captured }
    end

    context "when status is not captured" do
      let(:status) { "AUTHORIZED" }

      it { expect(payment_source).not_to be_captured }
    end
  end
end
