class CreateDevices < ActiveRecord::Migration

  def change

    create_table :devices do |t|
      t.string :key, null: false # device id
      t.string :token, null: false
      t.integer :user_id, null: true # devices that aren't logged in will have no user_id
      t.text :details, default: "{}", null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :devices, :key, unique: true
    add_index :devices, :token, unique: true
    add_index :devices, :user_id
    add_index :devices, :status
    

  end

end
