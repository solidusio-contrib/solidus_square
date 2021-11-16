# frozen_string_literal: true

module SolidusSquare
  class BasePresenter
    def self.square_payload(*args)
      new(*args).square_payload
    end

    def square_payload
      raise NotImplementedError
    end
  end
end
