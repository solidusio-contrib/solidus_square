# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusSquare
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_square'

    initializer "solidus_square.add_static_preference", after: "spree.register.payment_methods" do |app|
      Spree::Config.static_model_preferences.add(
        SolidusSquare::PaymentMethod,
        'square_credentials', {
          access_token: SolidusSquare.config.square_access_token,
          environment: SolidusSquare.config.square_environment,
          location_id: SolidusSquare.config.square_location_id,
          app_id: SolidusSquare.config.square_app_id,
          redirect_url: ENV['SQUARE_REDIRECT_URL']
        }
      )

      app.config.spree.payment_methods << SolidusSquare::PaymentMethod
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
