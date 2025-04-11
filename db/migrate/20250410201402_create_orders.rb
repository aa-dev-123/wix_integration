class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :external_reference_id
      t.string :subtotal
      t.integer :shipping
      t.string :tax
      t.string :discount
      t.string :total

      t.timestamps
    end
  end
end
