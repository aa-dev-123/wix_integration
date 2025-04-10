class RenameTypeAndDescription < ActiveRecord::Migration[6.1]
  def change
    rename_column :projects, :deescription, :description
    rename_column :projects, :type, :product_type
  end
end
