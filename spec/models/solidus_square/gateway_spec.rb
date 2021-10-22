# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Gateway do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:options) { { access_token: 'abcde', environment: 'sandbox' } }
  let(:described_instance) { described_class.new(options) }

  describe '#initialize' do
    it 'initialize options and client params' do
      expect(described_instance.options).to eq options
      expect(described_instance.client).to be_an_instance_of(::Square::Client)
    end
  end

  describe '#create_customer' do
    before do
      allow(::SolidusSquare::Customers::Create).to receive(:call)
    end

    it 'call SolidusSquare Customer Create class' do
      described_instance.create_customer(spree_user, spree_address)

      expect(::SolidusSquare::Customers::Create).to have_received(:call).with(
        client: described_instance.client,
        spree_user: spree_user,
        spree_address: spree_address
      )
    end
  end

  describe "#capture" do
    subject(:response) { SolidusSquare::Gateway.new(location_id: 12345).capture(nil, nil, gateway_options)}

    let(:order) { create(:order) }
    let(:gateway_options) do
      OpenStruct.new(order: order)
    end
    let(:checkout_response) do
      OpenStruct.new(body: OpenStruct.new(id: 12))
    end

    # before do
    #   stub_request(%r"")
    # end

    context "when response is unsuccessfull" do
      it "should return an active merchant billing response" do
        expect(response).to be_an_instance_of(ActiveMerchant::Billing::Response)
      end

      it "should contain an error message" do
        # binding.pry
        expect(response.message).not_to be_empty
      end
    end
  end
end
