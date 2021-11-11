class AddVersionToSolidusSquarePaymentSources < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_square_payment_sources, :version, :integer
  end
end
