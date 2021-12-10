# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Refunds::Create do
  subject(:refund_payment) {
    described_class.new(client: client, amount: amount, payment_id: payment_id)
  }

  let(:captured_payment) { create_and_capture_payment_on_sandbox }
  let(:payment_id) { captured_payment[:id] }
  let(:amount) { captured_payment[:amount_money][:amount] }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  describe "#call", vcr: true do
    let(:expected_attributes) do
      {
        amount_money: {
          amount: amount,
          currency: "USD"
        },
        payment_id: payment_id
      }
    end

    it "creates a refund with the correct data" do
      expect(refund_payment.call).to include(expected_attributes)
    end
  end
end
