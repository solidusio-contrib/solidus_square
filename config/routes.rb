# frozen_string_literal: true

SolidusSquare::Engine.routes.draw do
  # Add your extension routes here
  get 'customers', to: '/solidus_square/customers#index'

  # post '/api/checkouts/:id/square', to: 'solidus_square/api/checkout#create', as: 'api_checkouts_square' # API

  # Uncomment this two lines to activate the endpoints for the Square hosted checkout workflow.
  # get 'square_checkout', to: '/solidus_square/callback_actions#square_checkout'
  # get 'complete_checkout', to: '/solidus_square/callback_actions#complete_checkout'

  # Uncomment this line to activate the endpoint for the Square order.updated Webhook
  # post "webhooks/square", to: '/solidus_square/webhooks#update'

  post "api/payments/square", to: '/solidus_square/api/payments#create', as: "payments_square"
end
