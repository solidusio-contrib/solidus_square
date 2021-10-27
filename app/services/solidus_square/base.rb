# frozen_string_literal: true

module SolidusSquare
  class Base
    def initialize(*args); end

    def call
      raise NotImplementedError
    end

    def self.call(*args)
      new(*args).call
    end

    private

    def idempotency_key
      SecureRandom.uuid
    end

    def handle_square_result(square_result)
      return yield(square_result) if square_result.success?

      raise ServerError, square_result.errors.to_json
    end
  end
end
