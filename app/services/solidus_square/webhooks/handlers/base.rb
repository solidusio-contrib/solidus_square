# frozen_string_literal: true

require "square"
module SolidusSquare
  module Webhooks
    module Handlers
      class Base
        attr_reader :params

        def initialize(params)
          @params = params
        end

        def self.call(params)
          new(params).call
        end

        def call
          raise NotImplementedError, 'Missing #call method on class'
        end

        private

        def square_payment_method
          SolidusSquare.config.square_payment_method
        end
      end
    end
  end
end
