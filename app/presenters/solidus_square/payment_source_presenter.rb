# frozen_string_literal: true

module SolidusSquare
  class PaymentSourcePresenter < BasePresenter
    attr_reader :params

    def initialize(params)
      @params = params

      super()
    end

    def square_payload
      construct_payment_source
    end

    private

    def construct_payment_source
      {
        version: version,
        avs_status: payment_data[:card_details][:avs_status],
        expiration_date: expiration_date,
        # rubocop:disable Naming/VariableNumber
        last_digits: card_details[:last_4],
        # rubocop:enable Naming/VariableNumber
        card_brand: card_details[:card_brand],
        card_type: card_details[:card_type],
        status: payment_data[:card_details][:status],
        square_payment_id: payment_data[:id]
      }
    end

    def version
      payment_data[:version]
    end

    def payment_data
      params[:data][:object][:payment]
    end

    def card_details
      payment_data[:card_details][:card]
    end

    def expiration_date
      "#{card_details[:exp_month]}/#{card_details[:exp_year]}"
    end
  end
end
