# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::CallbackActionsController', type: :request do
  let(:current_user) { create(:user) }
  let(:order) { create(:order_with_line_items, user: current_user) }
  let(:payment_method) { create(:square_payment_method, preferred_redirect_url: redirect_url) }
  let(:redirect_url) { "https://github.com" }

  around do |test|
    Rails.application.routes.draw do
      get 'square_checkout', to: 'solidus_square/callback_actions#square_checkout'
      get 'complete_checkout', to: 'solidus_square/callback_actions#complete_checkout'

      mount Spree::Core::Engine, at: '/'
    end
    test.run
    Rails.application.reload_routes!
  end

  before do
    allow(::SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SolidusSquare::CallbackActionsController).to receive(:spree_current_user)
      .and_return(current_user)
    # rubocop:enable RSpec/AnyInstance
  end

  describe '#square_checkout', vcr: true do
    before do
      payment_method.preferred_redirect_url = "https://github.com"
      payment_method.save!
      allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
    end

    context "when respond to html", vcr: true do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Spree::Core::ControllerHelpers::Order).to receive(:current_order).and_return(order)
        # rubocop:enable RSpec/AnyInstance
        get square_checkout_path(order_number: order.number)
      end

      it "has http status 302" do
        expect(response.status).to eq(302)
        expect(response.location).to match %r/https:\/\/connect.squareupsandbox.com\/v2\/checkout\?/
      end
    end
  end

  describe "#complete_checkout" do
    before do
      get complete_checkout_path(order_number: order.number)
    end

    it "returns the checkout_page_url" do
      expect(response.location).to match(redirect_url)
    end

    it "creates a new order" do
      expect(Spree::Order.all.size).to eq(2)
    end

    it "creates a new order with the same user_id" do
      new_order = Spree::Order.last
      expect(order.user_id).to eq(new_order.user_id)
      expect(order).not_to eq(new_order)
    end
  end
end
