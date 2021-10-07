# frozen_string_literal: true

require 'spec_helper'

describe ::SolidusSquare::Refunds::Create do
  subject(:service) do
    described_class.call({ client: '', idempotency_key: key, payment_id: payment_id, amount: amount, currency: currency })
  end

  let(:key) { '11111' }
  let(:payment_id) { '2222' }
  let(:amount) { 100 }
  let(:currency) { 'USD' }

  before do
    allow_any_instance_of(described_class).to receive(:initiate_refund).and_return({ 'id' => 111 })
  end

  it 'returns existing customer data' do
    expect(service['id']).to eq 111
  end
end
