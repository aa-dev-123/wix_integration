class Projects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :deescription
      t.integer :price
      t.string :currency
      t.string :type
      t.string :sku
      t.timestamps
    end
  end
end
