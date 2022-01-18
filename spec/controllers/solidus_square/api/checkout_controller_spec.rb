# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::Api::CheckoutController', type: :request do
  let(:current_user) { create(:user) }
  let(:order) { create(:order_with_line_items, user: current_user) }
  let(:payment_method) { create(:square_payment_method, preferred_redirect_url: redirect_url) }
  let(:redirect_url) { "https://github.com" }

  around do |test|
    Rails.application.routes.draw do
      post '/api/checkouts/:id/square', to: 'solidus_square/api/checkout#create', as: 'api_checkouts_square'
      get '/checkout/square/complete',
        to: 'solidus_square/callback_actions#complete_checkout',
        as: :square_checkout_complete

      mount Spree::Core::Engine, at: '/'
    end
    test.run
    Rails.application.reload_routes!
  end

  before do
    allow(::SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
  end

  describe '#create', vcr: true do
    before do
      payment_method.preferred_redirect_url = "https://github.com"
      payment_method.save!
      allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
    end

    context "when format is json", vcr: true do
      let(:json_response) { JSON.parse(response.body) }

      before do
        post api_checkouts_square_path(id: order.number, order_token: order.guest_token, format: :json)
      end

      it "returns the square URL where redirect the user" do
        expect(response.status).to eq(200)
        expect(json_response['checkout_page_url']).to match %r/https:\/\/connect.squareupsandbox.com\/v2\/checkout\?/
      end
    end
  end
end
