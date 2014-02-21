class CreateDeviceAuthDevices < ActiveRecord::Migration

  #this migration is generated by devices_auth gem

  def change

    create_table :device_auth_devices do |t|
      t.string :key, null: false # device id
      t.string :token, null: false
      t.integer :user_id, null: true # devices that aren't logged in will have no user_id
      t.text :details, default: "{}", null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :device_auth_devices, :key, unique: true
    add_index :device_auth_devices, :token, unique: true
    add_index :device_auth_devices, :user_id
    add_index :device_auth_devices, :status
    

  end

end
