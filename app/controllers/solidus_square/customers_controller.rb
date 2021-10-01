# frozen_string_literal: true

module SolidusSquare
  class CustomersController < SolidusSquare::BaseController
    def index
      render json: { message: 'success' }, status: :ok
    end
  end
end
