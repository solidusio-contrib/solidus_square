class CreateSolidusSquarePaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_square_payment_sources do |t|
      t.string :token
      t.integer :payment_method_id, index: true

      t.timestamps
    end

    add_foreign_key :solidus_square_payment_sources, :spree_payment_methods, column: :payment_method_id
  end
end
