# frozen_string_literal: true

RSpec.describe SolidusSquare::PaymentSyncService do
  subject(:handler) { described_class.new(params) }

  let(:options) {
    { access_token: ENV['SQUARE_ACCESS_TOKEN'] || "abcde", environment: 'sandbox',
      location_id: ENV['SQUARE_LOCATION_ID'] || 'location' }
  }
  let(:payment_method) { create(:square_payment_method) }
  let(:gateway) { SolidusSquare::Gateway.new(options) }
  let!(:order) { create(:order_ready_to_complete, number: "R919717664", state: 'payment', payment_state: nil) }
  let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order: order, hosted_checkout: true) }
  let(:state) { "COMPLETED" }
  let(:params) do
    {
      type: "payment.updated",
      data: {
        object: {
          payment: square_payment_response(amount: order.total, order_id: square_order_id)
        }
      }
    }
  end

  before do
    allow(payment_method).to receive(:gateway).and_return(gateway)
    allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
  end

  describe "#call" do
    context "when version number is the same or less than the params", vcr: true do
      let(:payment) { order.reload.payments.last }
      let(:payment_source) { payment.payment_source }

      it "creates a Spree::Payment" do
        expect { handler.call }.to change { order.reload.payments.count }.by(1)

        expect(payment).to be_an_instance_of(Spree::Payment)
      end

      context "when payment source is captured" do
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
          handler.call
        end

        it { expect(payment.state).to match("completed") }

        it { expect(payment_source).to have_attributes(expected_attributes) }
      end

      context "when payment source is not captured" do
        before do
          params[:data][:object][:payment][:card_details][:status] = "PENDING"
        end

        it "doesn't complete the payment" do
          expect { handler.call }.not_to change(payment, :state)
        end
      end
    end

    context "when the version number is higher than the params", vcr: true do
      let(:payment_source) {  SolidusSquare::PaymentSource.find_by(token: square_order_id) }

      before do
        handler.call
        params[:data][:object][:payment][:card_details][:status] = "PENDING"
        params[:data][:object][:payment][:version] = 2
      end

      it "doesn't change the status of the payment source" do
        expect { handler.call }.not_to change(payment_source, :status)
      end
    end

    context "when the order is not in payment state", vcr: true do
      let!(:order) { create(:order_ready_to_complete, number: "R919717664", state: 'cart', payment_state: nil) }

      it "doesn't complete the order" do
        expect { handler.call }.not_to change(order, :state)
      end
    end
  end
end
