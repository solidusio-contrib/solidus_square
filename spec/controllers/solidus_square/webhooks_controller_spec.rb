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
    let!(:order) { create(:order_ready_to_complete, number: "R919717663", state: 'payment', payment_state: nil) }
    let(:square_order_id) { find_or_create_square_order_id_on_sandbox(order) }
    let(:params) do
      {
        type: "order.updated",
        data: {
          id: square_order_id,
          object: {
            order_updated: {
              state: 'COMPLETED'
            }
          }
        }
      }
    end

    context "when valid", vcr: true do
      let(:payment) { order.payments.last }

      before do
        allow(payment_method).to receive(:gateway).and_return(gateway)
        allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
      end

      it "creates a Spree::Payment" do
        expect { endpoint_call }.to change { order.reload.payments.count }.by(1)

        expect(payment).to be_an_instance_of(Spree::Payment)
        expect(payment).to have_attributes(amount: order.total)
      end

      it "updates the order state to complete" do
        expect { endpoint_call }.to change { order.reload.state }.from('payment').to('complete')
      end

      it "have http status success" do
        endpoint_call

        expect(response).to have_http_status(:success)
      end
    end

    context "when not valid", vcr: true do
      before do
        allow(::SolidusSquare::Webhooks::Sorter).to receive(:call).and_raise(ActiveRecord::RecordInvalid)
      end

      it "does not create a Spree::Payment" do
        expect { endpoint_call }.not_to(change { order.payments.count })
      end

      it "does not updates the order state to complete" do
        endpoint_call

        expect(order).not_to be_complete
      end

      it "have http status unprocessable entity" do
        endpoint_call

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
