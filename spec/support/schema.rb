ActiveRecord::Schema.define(version: 20140212210648) do
  
  create_table "devices_auth_devices", force: true do |t|
    t.string   "key",                           null: false
    t.string   "token",                         null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "details",    default: "{}",     null: false
    t.string   "status",     default: "active", null: false
  end
  
  
  create_table "users", force: true do |t|
    t.string 'name'
    t.string 'token'
  end
  
end