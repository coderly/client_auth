class CreateClientAuthIdentities < ActiveRecord::Migration
  def change
    create_table :client_auth_credentials_reset_request do |t|
      t.string :token
      t.datetime :expires_at
      t.references :identity
      t.timestamps
    end

    add_index :client_auth_credentials_reset_request, :token, unique: true
  end
end
