class CreateClientAuthIdentities < ActiveRecord::Migration
  def change
    create_table :client_auth_password_reset_request do |t|
      t.string :token
      t.datetime :expires_at
      t.references :identity
      t.boolean :used
      t.timestamps
    end

    add_index :client_auth_password_reset_request, :token, unique: true
  end
end
