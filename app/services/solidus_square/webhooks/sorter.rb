# frozen_string_literal: true

module SolidusSquare
  module Webhooks
    class Sorter
      def self.call(params)
        new(params).call
      end

      def initialize(params)
        @params = params
      end

      def call
        handler&.call(@params)
      end

      private

      def handler
        class_name = event_type.split(".")
                               .map(&:capitalize)
                               .join

        return unless SolidusSquare::Webhooks::Handlers.const_defined?(class_name)

        SolidusSquare::Webhooks::Handlers.const_get(class_name)
      end

      def event_type
        @params[:type]
      end
    end
  end
end
