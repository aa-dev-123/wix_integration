class CreateOrderLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_line_items do |t|
      t.references :project, foreign_key: true
      t.references :order, foreign_key: true
      t.string :quantity
      t.integer :price
      t.string :total_price
      t.string :discount
      t.string :tax

      t.timestamps
    end
  end
end
