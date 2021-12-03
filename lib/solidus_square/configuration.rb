# frozen_string_literal: true

module SolidusSquare
  class Configuration
    # Define here the settings for this extension, e.g.:
    #
    # attr_accessor :my_setting
    attr_accessor :square_access_token, :square_environment, :square_location_id, :square_payment_method, :square_app_id
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
