# frozen_string_literal: true

RSpec.describe SolidusSquare::Webhooks::Handlers::PaymentUpdated do
  subject(:handler) { described_class.new("test") }

  before do
    allow(SolidusSquare::PaymentSyncService).to receive(:call)
  end

  it "calls the PaymentSyncService" do
    handler.call
    expect(SolidusSquare::PaymentSyncService).to have_received(:call).with("test")
  end
end
