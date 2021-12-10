# frozen_String_literal: true

RSpec.describe SolidusSquare::Payments::Capture, type: :request do
  subject(:capture_payment) {
    described_class.new(client: client, payment_id: square_payment_id)
  }

  let(:square_payment_id) { create_authorized_square_payment_id_on_sandbox }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  describe "#call", vcr: true do
    let(:expected_attributes) do
      {
        id: square_payment_id,
        status: "COMPLETED"
      }
    end

    it "captures a square payment" do
      expect(capture_payment.call).to include(expected_attributes)
    end
  end
end
