# frozen_String_literal: true

RSpec.describe SolidusSquare::Payments::Retrieve, type: :request do
  subject(:retrieve) { described_class.new(client: client, payment_id: square_payment_id) }

  let(:square_payment_id) { create_square_payment_id_on_sandbox }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  describe "#call", vcr: true do
    it "returns the payment information from the correct square payment" do
      expect(retrieve.call[:id]).to eq square_payment_id
    end
  end
end
