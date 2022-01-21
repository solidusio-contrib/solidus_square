# frozen_string_literal: true

RSpec.describe SolidusSquare::PaymentSourcePresenter do
  subject(:handler) { described_class.new(params) }

  let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order: order, hosted_checkout: true) }
  let(:payment_method_id) { 1 }
  let(:params) do
    {
      data: {
        object: {
          payment: square_payment_response
        }
      }
    }
  end

  describe "#call" do
    before do
      allow(SolidusSquare.config.square_payment_method).to receive(:id).and_return(payment_method_id)
    end

    let(:expected_output) do
      {
        version: 3,
        avs_status: "AVS_ACCEPTED",
        expiration_date: '11/2022',
        last_digits: "9029",
        card_brand: "MASTERCARD",
        card_type: "CREDIT",
        status: "CAPTURED"
      }
    end

    it { expect(handler.square_payload).to match(expected_output) }
  end
end
