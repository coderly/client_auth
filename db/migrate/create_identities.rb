class CreateClientAuthDevices < ActiveRecord::Migration
  def change

    create_table :client_auth_devices do |t|
      t.string :key, null: false # device id
      t.string :token, null: false

      t.integer :owner_id
      t.string :owner_type

      t.text :details, default: "{}", null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :client_auth_devices, :key, unique: true
    add_index :client_auth_devices, :token, unique: true
    add_index :client_auth_devices, [:owner_id, :owner_type]
    add_index :client_auth_devices, :status

  end
end
