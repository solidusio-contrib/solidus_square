# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusSquare
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_square'

    initializer "solidus_square.add_static_preference", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusSquare::PaymentMethod
      Spree::PermittedAttributes.source_attributes.concat [:nonce]
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
