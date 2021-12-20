class AddCardInfoToSquarePaymentSources < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_square_payment_sources, :avs_status, :string
    add_column :solidus_square_payment_sources, :expiration_date, :string
    add_column :solidus_square_payment_sources, :last_digits, :string
    add_column :solidus_square_payment_sources, :card_brand, :string
    add_column :solidus_square_payment_sources, :card_type, :string
    add_column :solidus_square_payment_sources, :status, :string
  end
end
