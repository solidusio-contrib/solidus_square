# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::PaymentsController', type: :request do
  describe "#create" do
    subject(:endpoint_call) {
      post '/solidus_square/api/payments/square', params: params, headers: { "X-Spree-Order-Token": order.guest_token }
    }

    let(:order) { create(:order) }
    let(:payment_method_id) { '12' }
    let(:params) do
      {
        payment: {
          order_number: order.number,
          source_id: "nonce",
          payment_method_id: payment_method_id
        }
      }
    end

    context "with valid params" do
      before do
        allow(SolidusSquare::CreatePaymentService).to receive(:call)
          .with(source_id: "nonce", order: order, payment_method_id: payment_method_id)
        endpoint_call
      end

      it "render status ok" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when there is an error" do
      before do
        allow(SolidusSquare::CreatePaymentService).to receive(:call)
          .with(source_id: "nonce", order: order, payment_method_id: payment_method_id)
          .and_raise(StandardError, "test error message")
        endpoint_call
      end

      it "render status unprocessable_entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the error message in the body" do
        expect(response.body).to include("test error message")
      end
    end
  end
end
