# frozen_String_literal: true

RSpec.describe SolidusSquare::Orders::Retrieve, type: :request do
  subject(:retrieve) { described_class.new(client: client, order_id: square_order_id) }

  let(:order) { create(:order_with_line_items) }
  let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order: order, hosted_checkout: true) }
  let(:client) do
    ::Square::Client.new(
      access_token: SolidusSquare.config.square_access_token,
      environment: "sandbox"
    )
  end

  describe "#call", vcr: true do
    it "returns the order information from the correct square order" do
      expect(retrieve.call[:id]).to eq square_order_id
    end
  end
end
