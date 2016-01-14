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

ActiveRecord::Schema.define(version: 20160114123812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "enabled"
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean  "public"
    t.integer  "stars_count"
    t.string   "slug"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "catalogues", ["slug"], name: "index_catalogues_on_slug", using: :btree
  add_index "catalogues", ["user_id"], name: "index_catalogues_on_user_id", using: :btree

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

  create_table "metadata", force: :cascade do |t|
    t.text     "metadata"
    t.integer  "thing_id"
    t.string   "thing_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "metadata", ["thing_type", "thing_id"], name: "index_metadata_on_thing_type_and_thing_id", using: :btree

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "stars", ["user_id", "thing_id"], name: "index_stars_on_user_id_and_thing_id", unique: true, using: :btree
  add_index "stars", ["user_id"], name: "index_stars_on_user_id", using: :btree

  create_table "things", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "public"
    t.integer  "stars_count",       default: 0
    t.string   "name"
    t.text     "code"
    t.string   "type"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "slug"
    t.string   "file_id"
    t.integer  "file_size"
    t.string   "file_content_type"
  end

  add_index "things", ["slug", "user_id"], name: "index_things_on_slug_and_user_id", unique: true, using: :btree
  add_index "things", ["type"], name: "index_things_on_type", using: :btree
  add_index "things", ["user_id"], name: "index_things_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.string   "website"
    t.string   "name"
    t.string   "organization"
    t.string   "place"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.integer  "ontotext_account",       default: 0
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
