class CreateClientAuthIdentities < ActiveRecord::Migration
  def change
    create_table :client_auth_identities do |t|
      t.string :type, null: false, default: 'ClientAuth::Identity'

      t.integer :user_id, null: false
      t.string :user_type, null: false

      t.string :provider, null: false
      t.string :provider_user_id, null: false
      t.text :details
    end

    add_index :client_auth_identities, [:user_id, :user_type, :provider], unique: true, name: 'client_auth_user_provider'
    add_index :client_auth_identities, [:provider, :provider_user_id], unique: true
  end
end
