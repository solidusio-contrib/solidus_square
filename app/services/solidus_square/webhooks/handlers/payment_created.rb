# frozen_string_literal: true

module SolidusSquare
  module Webhooks
    module Handlers
      class PaymentCreated < Base
        def call
          PaymentSyncService.call(params)
        end
      end
    end
  end
end
