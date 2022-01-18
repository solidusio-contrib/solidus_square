class CreateSolidusSquareCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_square_customers do |t|
      t.string :square_customer_ref
      t.references :user

      t.timestamps
    end
  end
end
