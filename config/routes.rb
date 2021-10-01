# frozen_string_literal: true

SolidusSquare::Engine.routes.draw do
  # Add your extension routes here
  get '/customers', to: '/solidus_square/customers#index'
end
