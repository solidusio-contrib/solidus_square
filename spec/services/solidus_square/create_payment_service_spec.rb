# frozen_string_literal: true

RSpec.describe SolidusSquare::CreatePaymentService do
  subject(:handler) { described_class.new(source_id: "nonce", order: order, payment_method_id: payment_method.id) }

  let(:options) {
    { access_token: ENV['SQUARE_ACCESS_TOKEN'] || "abcde", environment: 'sandbox',
      location_id: ENV['SQUARE_LOCATION_ID'] || 'location' }
  }
  let!(:payment_method) { create(:square_payment_method) }
  let(:gateway) { SolidusSquare::Gateway.new(options) }
  let!(:order) { create(:order_ready_to_complete, number: "R919717664", state: 'delivery', payment_state: nil) }
  let(:status) { "CAPTURED" }
  let(:square_response) { square_payment_response(amount: order.total, status: status) }
  let(:payment) { order.reload.payments.last }
  let(:payment_source) { payment.source }

  before do
    allow(Spree::PaymentMethod).to receive(:find).with(payment_method.id).and_return(payment_method)
    allow(gateway).to receive(:create_payment).and_return(square_response)
    allow(payment_method).to receive(:gateway).and_return(gateway)
  end

  describe "#call" do
    context "when order is in delivery state", vcr: true do
      it "creates a Spree::Payment" do
        expect { handler.call }.to change { order.reload.payments.count }.by(1)

        expect(payment).to be_an_instance_of(Spree::Payment)
      end

      it "change the order state to payment" do
        handler.call
        expect(order.reload.state).to match("payment")
      end
    end

    context "when order is not in delivery state", vcr: true do
      let!(:order) { create(:order_ready_to_complete, number: "R919717664", state: 'payment', payment_state: nil) }

      it "change the order state" do
        expect { handler.call }.not_to change(order, :state)
      end
    end

    it "add the nonce to the payment source" do
      handler.call
      expect(payment_source.nonce).to eq('nonce')
    end
  end
end
