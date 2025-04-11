class CreateShops < ActiveRecord::Migration[6.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :url
      t.string :external_shop_id
      t.references :authentication, null: false, foreign_key: true

      t.timestamps
    end
  end
end
