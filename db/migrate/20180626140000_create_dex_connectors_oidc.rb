class CreateDexConnectorsOidc < ActiveRecord::Migration
  def change
    create_table "dex_connectors_oidc", force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",               limit: 255
      t.string   "provider_url",       limit: 255
      t.string   "client_id",          limit: 255
      t.string   "client_secret",      limit: 255
      t.string   "callback_url",       limit: 255, default: "http://127.0.0.1:5556/callback"
      t.boolean  "basic_auth",                     default: true
    end
  end
end
