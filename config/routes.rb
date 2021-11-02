# frozen_string_literal: true

SolidusSquare::Engine.routes.draw do
  # Add your extension routes here
  get 'customers', to: '/solidus_square/customers#index'

  # Uncomment this line to activate the endpoint for the Square hosted checkout workflow.
  # post 'square_checkout', to: '/solidus_square/callback_actions#square_checkout'

  # Uncomment this line to activate the endpoint for the Square order.updated Webhook
  # patch "webhooks/square", to: '/solidus_square/webhooks#update'
end
