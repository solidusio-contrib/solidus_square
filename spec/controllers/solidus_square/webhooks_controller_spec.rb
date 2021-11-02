# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::WebhooksController', type: :request do
  describe '#update' do
    subject(:endpoint_call) { patch "/webhooks/square", params: params }

    around do |test|
      Rails.application.routes.draw do
        patch "webhooks/square", to: 'solidus_square/webhooks#update'
        mount Spree::Core::Engine, at: '/'
      end
      test.run
      Rails.application.reload_routes!
    end

    let(:options) {
      { access_token: ENV['SQUARE_ACCESS_TOKEN'] || "abcde", environment: 'sandbox', location_id: 'location' }
    }
    let(:gateway) { SolidusSquare::Gateway.new(options) }
    let(:payment_method) { create(:square_payment_method) }
    let!(:order) { create(:order_with_line_items, number: "R919717663") }
    let(:params) do
      {
        type: "order.updated",
        data: {
          id: "aCvoi0WsmnpeNRIs7BjEHVtarh4F",
          object: {
            order_updated: {
              state: "COMPLETED"
            }
          }
        }
      }
    end

    context "when valid", vcr: true do
      before do
        allow(payment_method).to receive(:gateway).and_return(gateway)
        allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
        endpoint_call
        order.reload
      end

      it "creates a Spree::Payment" do
        expect(order.payments.first).to be_an_instance_of(Spree::Payment)
      end

      it "updates the order state to complete" do
        expect(order).to be_complete
      end

      it "have http status success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when not valid" do
      before do
        allow(::SolidusSquare::Webhooks::Sorter).to receive(:call).and_raise(ActiveRecord::RecordInvalid)
        endpoint_call
      end

      it "does not create a Spree::Payment" do
        expect(order.payments).not_to be_any
      end

      it "does not updates the order state to complete" do
        expect(order).not_to be_complete
      end

      it "have http status unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
