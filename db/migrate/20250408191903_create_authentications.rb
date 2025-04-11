class CreateAuthentications < ActiveRecord::Migration[6.1]
  def change
    create_table :authentications do |t|
      t.string :token
      t.string :refresh_token

      t.timestamps
    end
  end
end
