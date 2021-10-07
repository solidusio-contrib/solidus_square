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
  end
end