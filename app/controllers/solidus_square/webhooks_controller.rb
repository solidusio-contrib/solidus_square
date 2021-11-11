# frozen_string_literal: true

module SolidusSquare
  class WebhooksController < BaseController
    def update
      ::SolidusSquare::Webhooks::Sorter.call(params)

      render json: {}, status: :ok
    rescue StandardError => e
      error_message = e.to_s
      logger.error error_message
      render json: { error: error_message }, status: :unprocessable_entity
    end
  end
end
