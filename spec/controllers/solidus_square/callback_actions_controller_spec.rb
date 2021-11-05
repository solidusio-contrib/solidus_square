# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::CallbackActionsController', type: :request do
  around do |test|
    Rails.application.routes.draw do
      post 'square_checkout', to: 'solidus_square/callback_actions#square_checkout'
      mount Spree::Core::Engine, at: '/'
    end
    test.run
    Rails.application.reload_routes!
  end

  describe '#square_checkout', vcr: true do
    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { create(:square_payment_method) }

    before do
      payment_method.preferred_redirect_url = "https://github.com"
      payment_method.save!
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Spree::Core::ControllerHelpers::Order).to receive(:current_order).and_return(order)
      # rubocop:enable RSpec/AnyInstance
      allow(SolidusSquare.config).to receive(:square_payment_method).and_return(payment_method)
    end

    context "when respond to html", vcr: true do
      before do
        post square_checkout_path(order_number: order.number)
      end

      it "has http status 302" do
        expect(response.status).to eq(302)
        expect(response.location).to match %r/https:\/\/connect.squareupsandbox.com\/v2\/checkout\?/
      end
    end
  end
end
