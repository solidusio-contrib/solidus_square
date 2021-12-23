# frozen_String_literal: true

RSpec.describe SolidusSquare::Payments::Create, type: :request do
  subject(:create_payment) {
    described_class.new(client: client, source_id: "nonce", amount: 19.99, auto_capture: false)
  }

  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  describe "#call", vcr: true do
    let(:external_details) { { type: "CHECK", source: "Food Delivery Service" } }
    let(:idempotency_key) { rand(1_000_000_000_000_000).to_s }
    let(:amount_money) { { currency: "USD" } }
    let(:payload) do
      {
        idempotency_key: idempotency_key,
        amount_money: amount_money,
        source_id: "EXTERNAL",
        external_details: external_details
      }
    end

    before do
      allow(client.payments).to receive(:create_payment).and_call_original
      allow(client.payments).to receive(:create_payment).with(hash_including(body:
        hash_including(source_id: "nonce"))) do |args|
        payload[:amount_money][:amount] = args[:body][:amount_money][:amount]
        client.payments.create_payment(body: payload)
      end
    end

    it "creates a square payment with the correct data" do
      expect(create_payment.call[:amount_money]).to match({ amount: 1999, currency: "USD" })
    end
  end
end
