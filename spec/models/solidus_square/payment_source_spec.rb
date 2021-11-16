require 'spec_helper'

RSpec.describe SolidusSquare::PaymentSource, type: :model do
  let(:payment_source) { described_class.new(token: "12345") }
  let(:payment_method) { create(:square_payment_method) }
  let(:status) { "CAPTURED" }
  let(:payment) { instance_double(Spree::Payment) }
  let(:gateway) { instance_double(SolidusSquare::Gateway) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:token) }
  end

  describe "#can_void?" do
    subject(:can_void?) { payment_source.can_void?(payment) }

    before do
      allow(payment).to receive(:payment_method).and_return(payment_method)
      allow(payment).to receive(:source).and_return(OpenStruct.new(square_payment_id: "12345"))
      allow(payment_method).to receive(:gateway).and_return(gateway)
      allow(gateway).to receive(:get_payment).and_return({ card_details: { status: status } })
    end

    context "when payment is captured" do
      it { expect(can_void?).to be_falsy }
    end

    context "when payment is not captured yet" do
      let(:status) { "AUTHORIZED" }

      it { expect(can_void?).to be_truthy }
    end
  end
end
