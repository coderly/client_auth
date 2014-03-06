ActiveRecord::Schema.define(version: 20140212210648) do
  
  create_table "client_auth_clients", force: true do |t|
    t.string   "key",                           null: false
    t.string   "token",                         null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "details",    default: "{}",     null: false
    t.string   "status",     default: "active", null: false
  end
  
  create_table "client_auth_identities", force: true do |t|
    t.string  "type",             default: "ClientAuth::Identity", null: false
    t.integer "user_id",                                           null: false
    t.string  "user_type",                                         null: false
    t.string  "provider",                                          null: false
    t.string  "provider_user_id",                                  null: false
    t.text    "details"
  end

  add_index "client_auth_identities", ["provider", "provider_user_id"], name: "index_client_auth_identities_on_provider_and_provider_user_id", unique: true, using: :btree
  add_index "client_auth_identities", ["user_id", "user_type", "provider"], name: "client_auth_user_provider", unique: true, using: :btree
  
  
  create_table "users", force: true do |t|
    t.string 'name'
    t.string 'token'
  end
end