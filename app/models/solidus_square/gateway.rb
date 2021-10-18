# frozen_string_literal: true

require 'square'

module SolidusSquare
  class Gateway
    attr_accessor :options, :client

    def initialize(options)
      @options = options
      @client = ::Square::Client.new(
        access_token: options[:access_token],
        environment: options[:environment]
      )
    end
  end
end
