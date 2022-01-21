class AddCustomerToSolidusSquarePaymentSource < ActiveRecord::Migration[6.1]
  def change
    add_reference :solidus_square_payment_sources, :customer
  end
end
