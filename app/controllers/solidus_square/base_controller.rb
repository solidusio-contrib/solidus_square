# frozen_string_literal: true

module SolidusSquare
  class BaseController < ::Spree::BaseController
    protect_from_forgery

    rescue_from ::ActiveRecord::RecordNotFound, with: :resource_not_found
    rescue_from ::CanCan::AccessDenied, with: :unauthorized

    private

    def resource_not_found
      respond_to do |format|
        format.html { redirect_to spree.cart_path, notice: I18n.t('solidus_square.resource_not_found') }
      end
    end

    def unauthorized
      respond_to do |format|
        format.html { redirect_to spree.cart_path, notice: I18n.t('solidus_square.unauthorized') }
      end
    end
  end
end
