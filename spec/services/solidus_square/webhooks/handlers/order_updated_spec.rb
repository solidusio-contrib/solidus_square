# frozen_string_literal: true

RSpec.describe SolidusSquare::Webhooks::Handlers::OrderUpdated do
  subject(:handler) { described_class.new(params) }

  let(:options) {
    { access_token: ENV['SQUARE_ACCESS_TOKEN'] || "abcde", environment: 'sandbox', location_id: 'location' }
  }
  let(:payment_method) { create(:square_payment_method) }
  let(:gateway) { SolidusSquare::Gateway.new(options) }
  let!(:order) { create(:order_with_line_items, number: "R919717663") }
  let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order) }
  let(:state) { "COMPLETED" }
  let(:params) do
    {
      type: "order.updated",
      data: {
        id: square_order_id,
        object: {
          order_updated: {
            state: state
          }
        }
      }
    }
  end

  describe "#call" do
    context "when square order state is completed", vcr: true do
      let(:payment) { order.payments.last }

      before do
        allow(payment_method).to receive(:gateway).and_return(gateway)
        allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
      end

      [
        :cart,
        :address,
        :delivery,
        :confirm,
        :complete
      ].each do |state|
        context "when spree state is #{state}" do
          let(:order) { create(:order_ready_to_complete, number: "R919717663", state: state, payment_state: nil) }

          it 'returns false' do
            expect(handler.call).to be_falsey
          end
        end
      end

      context "when spree state is payment" do
        let!(:order) { create(:order_ready_to_complete, number: "R919717663", state: 'payment', payment_state: nil) }

        it 'returns true' do
          expect(handler.call).to be_truthy
        end

        it "updates the orders state to complete" do
          expect { handler.call }.to change { order.reload.state }.from('payment').to('complete')
        end

        it "does create a Spree::Payment" do
          expect { handler.call }.to change { order.reload.payments.count }.by(1)

          expect(payment).to be_an_instance_of(Spree::Payment)
          expect(payment).to have_attributes(
            amount: order.total,
            payment_method: SolidusSquare.config.square_payment_method
          )
        end
      end

      context "when spree order is completed already" do
        let!(:order) { create(:completed_order_with_totals, number: "R919717663") }

        it "does not create a Spree::Payment" do
          expect { handler.call }.not_to change(order, :payments)
        end

        it "doesn't change the order state" do
          expect { handler.call }.not_to change(order, :state)
        end
      end
    end

    context "when square order state is not completed", vcr: true do
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
