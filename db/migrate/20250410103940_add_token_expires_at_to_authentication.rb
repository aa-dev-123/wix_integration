class AddTokenExpiresAtToAuthentication < ActiveRecord::Migration[6.1]
  def change
    add_column :authentications, :token_expires_at, :datetime
  end
end
