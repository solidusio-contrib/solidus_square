# frozen_string_literal: true

RSpec.describe SolidusSquare::Webhooks::Handlers::OrderUpdated do
  subject(:handler) { described_class.new(params) }

  let(:options) {
    { access_token: ENV['SQUARE_ACCESS_TOKEN'] || "abcde", environment: 'sandbox', location_id: 'location' }
  }
  let(:payment_method) { create(:square_payment_method) }
  let(:gateway) { SolidusSquare::Gateway.new(options) }
  let!(:order) { create(:order_with_line_items, number: "R919717663") }
  let(:state) { "COMPLETED" }
  let(:params) do
    {
      type: "order.updated",
      data: {
        id: "aCvoi0WsmnpeNRIs7BjEHVtarh4F",
        object: {
          order_updated: {
            state: state
          }
        }
      }
    }
  end

  describe "#call" do
    context "when state is completed", vcr: true do
      before do
        allow(payment_method).to receive(:gateway).and_return(gateway)
        allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
      end

      context "when order is not completed yet" do
        before do
          handler.call
          order.reload
        end

        it "update the orders state to complete" do
          expect(order).to be_complete
        end

        it "does create a Spree::Payment" do
          expect(order.payments.first).to be_an_instance_of(Spree::Payment)
        end
      end

      context "when order is completed already" do
        before do
          order.update(state: "complete")
          handler.call
        end

        it "does not create a Spree::Payment" do
          expect(order.payments).not_to be_any
        end
      end
    end

    context "when state is not completed" do
      before do
        handler.call
        order.reload
      end

      let(:state) { "NOT_COMPLETED" }

      it "does not update the orders state to complete" do
        expect(order).not_to be_complete
      end

      it "does not create a Spree::Payment" do
        expect(order.payments).not_to be_any
      end
    end
  end
end
