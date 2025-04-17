class AddDescriptionToShop < ActiveRecord::Migration[6.1]
  def change
    add_column :shops, :description, :string
  end
end
