# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::WebhooksController', type: :request do
  describe '#update' do
    subject(:endpoint_call) { post "/webhooks/square", params: params }

    let(:params) do
      {
        type: "payment.updated",
        data: {
          object: {
            payment: {
              amount_money: {
                amount: "123"
              },
              card_details: {
                status: "CAPTURED",
                card: {
                  card_brand: "MASTERCARD",
                  # rubocop:disable Naming/VariableNumber
                  last_4: "9029",
                  # rubocop:enable Naming/VariableNumber
                  exp_month: "11",
                  exp_year: "2022",
                  card_type: "CREDIT"
                },
                avs_status: "AVS_ACCEPTED",
              },
              order_id: "1234",
              version: "3"
            }
          }
        }
      }
    end

    around do |test|
      Rails.application.routes.draw do
        post "webhooks/square", to: 'solidus_square/webhooks#update'
        mount Spree::Core::Engine, at: '/'
      end
      test.run
      Rails.application.reload_routes!
    end

    context "when valid" do
      let(:expected_params) { ActionController::Parameters.new(params) }

      before do
        allow(::SolidusSquare::Webhooks::Sorter).to receive(:call)
        endpoint_call
        expected_params[:controller] = "solidus_square/webhooks"
        expected_params[:action] = "update"
      end

      it "have http status success" do
        expect(response).to have_http_status(:success)
      end

      it "calls the webhook sorter with the correct params" do
        expect(SolidusSquare::Webhooks::Sorter).to have_received(:call).with(expected_params)
      end
    end

    context "when not valid" do
      before do
        allow(::SolidusSquare::Webhooks::Sorter).to receive(:call).and_raise(ActiveRecord::RecordInvalid)
        endpoint_call
      end

      it "have http status unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
