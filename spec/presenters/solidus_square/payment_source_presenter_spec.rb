# frozen_string_literal: true

RSpec.describe SolidusSquare::PaymentSourcePresenter do
  subject(:handler) { described_class.new(params) }

  let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order: order, hosted_checkout: true) }
  let(:payment_method_id) { 1 }
  let(:params) do
    {
      data: {
        object: {
          payment: {
            id: 123,
            card_details: {
              status: "CAPTURED",
              card: {
                card_brand: "MASTERCARD",
                # rubocop:disable Naming/VariableNumber
                last_4: "9029",
                # rubocop:enable Naming/VariableNumber
                exp_month: 11,
                exp_year: 2022,
                card_type: "CREDIT"
              },
              avs_status: "AVS_ACCEPTED",
            },
            version: 3,
            order_id: 12
          }
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
        status: "CAPTURED",
        square_payment_id: 123,
        token: 12
      }
    end

    it { expect(handler.square_payload).to match(expected_output) }
  end
end
