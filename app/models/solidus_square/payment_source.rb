# frozen_string_literal: true

module SolidusSquare
  class PaymentSource < SolidusSupport.payment_source_parent_class
    self.table_name = 'solidus_square_payment_sources'

    validates :token, presence: true
  end
end
