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

ActiveRecord::Schema.define(version: 20180112102416) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "enabled", default: false, null: false
    t.string "name"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dbm_id"
    t.index ["key"], name: "index_api_keys_on_key"
  end

  create_table "arango_db_queries", id: :serial, force: :cascade do |t|
    t.integer "query_id"
    t.integer "arango_db_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arango_db_id"], name: "index_arango_db_queries_on_arango_db_id"
    t.index ["query_id"], name: "index_arango_db_queries_on_query_id"
  end

  create_table "catalogue_records", id: :serial, force: :cascade do |t|
    t.integer "catalogue_id"
    t.integer "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "catalogue_stars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "catalogue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_catalogue_stars_on_user_id"
  end

  create_table "catalogues", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.boolean "public", default: false, null: false
    t.integer "stars_count", default: 0
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_catalogues_on_slug"
    t.index ["user_id"], name: "index_catalogues_on_user_id"
  end

  create_table "data_page_queriable_data_stores", id: :serial, force: :cascade do |t|
    t.integer "data_page_id"
    t.integer "queriable_data_store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_page_id"], name: "index_data_page_queriable_data_stores_on_data_page_id"
    t.index ["queriable_data_store_id"], name: "index_datapages_queriable_data_stores"
  end

  create_table "data_page_widgets", id: :serial, force: :cascade do |t|
    t.integer "data_page_id"
    t.integer "widget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_page_id"], name: "index_data_page_widgets_on_data_page_id"
    t.index ["widget_id"], name: "index_data_page_widgets_on_widget_id"
  end

  create_table "dbm_accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "encrypted_password"
    t.integer "dbm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "enabled"
    t.boolean "public", default: false
    t.index ["dbm_id"], name: "index_dbm_accounts_on_dbm_id"
  end

  create_table "dbms", id: :serial, force: :cascade do |t|
    t.string "type"
    t.jsonb "configuration"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_dbms_on_user_id"
  end

  create_table "flipflop_features", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "queriable_data_store_queries", id: :serial, force: :cascade do |t|
    t.integer "queriable_data_store_id"
    t.integer "query_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["queriable_data_store_id"], name: "index_queriable_data_store_queries_on_queriable_data_store_id"
    t.index ["query_id"], name: "index_queriable_data_store_queries_on_query_id"
  end

  create_table "rdf_repos", id: :serial, force: :cascade do |t|
    t.jsonb "configuration"
    t.integer "dbm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dbm_id"], name: "index_rdf_repos_on_dbm_id"
  end

  create_table "sparql_endpoint_queries", id: :serial, force: :cascade do |t|
    t.integer "query_id"
    t.integer "sparql_endpoint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_id"], name: "index_sparql_endpoint_queries_on_query_id"
    t.index ["sparql_endpoint_id"], name: "index_sparql_endpoint_queries_on_sparql_endpoint_id"
  end

  create_table "sparql_endpoints", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "thing_id"], name: "index_stars_on_user_id_and_thing_id", unique: true
    t.index ["user_id"], name: "index_stars_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "thing_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "thing_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "thing_desc_idx"
  end

  create_table "things", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "public", default: false, null: false
    t.integer "stars_count", default: 0
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "file_id"
    t.integer "file_size"
    t.string "file_content_type"
    t.jsonb "metadata"
    t.jsonb "configuration"
    t.integer "parent_id"
    t.string "original_filename"
    t.string "state", default: "repo_created"
    t.integer "rdf_repo_id"
    t.integer "dbm_id"
    t.index ["slug", "user_id", "type"], name: "index_things_on_slug_and_user_id_and_type", unique: true
    t.index ["type"], name: "index_things_on_type"
    t.index ["user_id"], name: "index_things_on_user_id"
  end

  create_table "upwizards", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "task"
    t.integer "user_id"
    t.string "file_id"
    t.integer "file_size"
    t.string "file_content_type"
    t.string "original_filename"
    t.string "redirect_step"
    t.integer "radio_thing_id"
    t.jsonb "trace"
    t.string "transformed_file_id"
    t.integer "transformed_file_size"
    t.string "transformed_file_type"
    t.string "current_file_type"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.string "name"
    t.string "organization"
    t.string "place"
    t.string "provider"
    t.string "uid"
    t.string "image"
    t.string "username"
    t.integer "ontotext_account", default: 0
    t.boolean "isadmin", default: false
    t.integer "quota_sparql_count", default: 10
    t.integer "quota_sparql_ktriples", default: 10240
    t.integer "quota_transformation_count", default: 100
    t.integer "quota_filestore_count", default: 100
    t.integer "quota_filestore_ksize", default: 1048576
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "catalogues", "users"
end
