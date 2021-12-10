# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Payments::Void do
  let(:void) { described_class.new(client: client, payment_id: payment_id) }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end
  let(:payment_id) { create_authorized_square_payment_id_on_sandbox }

  describe '#call', vcr: true do
    subject(:call) { void.call }

    it "voids the payment" do
      expect(call).to include(id: payment_id, status: 'CANCELED')
    end
  end
end
