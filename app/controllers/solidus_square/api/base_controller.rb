# frozen_string_literal: true

module SolidusSquare
  module Api
    class BaseController < ::Spree::BaseController
      protect_from_forgery unless: -> { request.format.json? }

      rescue_from ::ActiveRecord::RecordNotFound, with: :resource_not_found
      rescue_from ::CanCan::AccessDenied, with: :unauthorized

      private

      def order_token
        request.headers["X-Spree-Order-Token"] || params[:order_token]
      end

      def resource_not_found
        respond_to do |format|
          format.json { render json: { error: I18n.t('solidus_square.resource_not_found') }, status: :not_found }
        end
      end

      def unauthorized
        respond_to do |format|
          format.json { render json: { error: I18n.t('solidus_square.unauthorized') }, status: :unauthorized }
        end
      end
    end
  end
end
