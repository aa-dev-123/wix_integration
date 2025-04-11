class AddUidToAuthentication < ActiveRecord::Migration[6.1]
  def change
    add_column :authentications, :uid, :string
    add_index :authentications, :uid, unique: true
  end
end
