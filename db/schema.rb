# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160616131136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "enabled",    default: false, null: false
    t.string   "name"
    t.string   "key"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree

  create_table "catalogue_records", force: :cascade do |t|
    t.integer  "catalogue_id"
    t.integer  "thing_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "catalogue_stars", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "catalogue_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "catalogue_stars", ["user_id"], name: "index_catalogue_stars_on_user_id", using: :btree

  create_table "catalogues", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "public",      default: false, null: false
    t.integer  "stars_count", default: 0
    t.string   "slug"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "catalogues", ["slug"], name: "index_catalogues_on_slug", using: :btree
  add_index "catalogues", ["user_id"], name: "index_catalogues_on_user_id", using: :btree

  create_table "data_page_queriable_data_stores", force: :cascade do |t|
    t.integer  "data_page_id"
    t.integer  "queriable_data_store_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "data_page_queriable_data_stores", ["data_page_id"], name: "index_data_page_queriable_data_stores_on_data_page_id", using: :btree
  add_index "data_page_queriable_data_stores", ["queriable_data_store_id"], name: "index_datapages_queriable_data_stores", using: :btree

  create_table "data_page_widgets", force: :cascade do |t|
    t.integer  "data_page_id"
    t.integer  "widget_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "data_page_widgets", ["data_page_id"], name: "index_data_page_widgets_on_data_page_id", using: :btree
  add_index "data_page_widgets", ["widget_id"], name: "index_data_page_widgets_on_widget_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.string   "key",                        null: false
    t.boolean  "enabled",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "queriable_data_store_queries", force: :cascade do |t|
    t.integer  "queriable_data_store_id"
    t.integer  "query_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "queriable_data_store_queries", ["queriable_data_store_id"], name: "index_queriable_data_store_queries_on_queriable_data_store_id", using: :btree
  add_index "queriable_data_store_queries", ["query_id"], name: "index_queriable_data_store_queries_on_query_id", using: :btree

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "stars", ["user_id", "thing_id"], name: "index_stars_on_user_id_and_thing_id", unique: true, using: :btree
  add_index "stars", ["user_id"], name: "index_stars_on_user_id", using: :btree

  create_table "thing_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "thing_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "thing_anc_desc_idx", unique: true, using: :btree
  add_index "thing_hierarchies", ["descendant_id"], name: "thing_desc_idx", using: :btree

  create_table "things", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "public",            default: false, null: false
    t.integer  "stars_count",       default: 0
    t.string   "name"
    t.string   "type"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "slug"
    t.string   "file_id"
    t.integer  "file_size"
    t.string   "file_content_type"
    t.jsonb    "metadata"
    t.jsonb    "configuration"
    t.integer  "parent_id"
  end

  add_index "things", ["slug", "user_id", "type"], name: "index_things_on_slug_and_user_id_and_type", unique: true, using: :btree
  add_index "things", ["type"], name: "index_things_on_type", using: :btree
  add_index "things", ["user_id"], name: "index_things_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "website"
    t.string   "name"
    t.string   "organization"
    t.string   "place"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.string   "username"
    t.integer  "ontotext_account",       default: 0
    t.boolean  "isadmin",                default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "catalogues", "users"
end
