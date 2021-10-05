# frozen_string_literal: true

require 'spec_helper'

describe ::SolidusSquare::Customers::Create do
  subject(:service) do
    described_class.call({ client: '', spree_user: spree_user, spree_address: spree_address })
  end

  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }

  context 'when customer already exists' do
    before do
      allow_any_instance_of(described_class).to receive(:search_customer).and_return({ 'id' => 111 })
    end

    it 'returns existing customer data' do
      expect(service['id']).to eq 111
    end
  end

  context 'when customer is new' do
    before do
      allow_any_instance_of(described_class).to receive(:search_customer).and_return([])
      allow_any_instance_of(described_class).to receive(:create_customer).and_return({ 'id' => 111 })
    end

    it 'returns new customer data' do
      expect(service['id']).to eq 111
    end
  end
end
