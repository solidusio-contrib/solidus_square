# frozen_string_literal: true

SolidusSquare::Engine.routes.draw do
  # Add your extension routes here
  get '/customers', to: '/solidus_square/customers#index'
  post '/order-complete', to: 'solidus_square/callbacks#order_complete'
end
