# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_23_183139) do
  create_table "clicks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "country_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "url_id"
    t.index ["url_id"], name: "index_clicks_on_url_id"
  end

  create_table "frequently_asked_questions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", precision: nil, null: false
    t.string "header"
    t.text "question"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "groups_users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "group_id"
    t.boolean "notify_user_changes", default: false, null: false
    t.integer "user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "ip2location_db1", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "country_code", limit: 2
    t.string "country_name"
    t.integer "ip_from", unsigned: true
    t.integer "ip_to", unsigned: true
    t.index ["ip_from", "ip_to"], name: "index_ip2location_db1_on_ip_from_and_ip_to"
    t.index ["ip_from"], name: "index_ip2location_db1_on_ip_from"
    t.index ["ip_to"], name: "index_ip2location_db1_on_ip_to"
  end

  create_table "perid_umndid", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "perid"
    t.string "uid"
    t.string "umndid"
  end

  create_table "starburst_announcement_views", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "announcement_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id", "announcement_id"], name: "starburst_announcement_view_index", unique: true
  end

  create_table "starburst_announcements", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body"
    t.text "category"
    t.datetime "created_at", precision: nil
    t.text "limit_to_users"
    t.datetime "start_delivering_at", precision: nil
    t.datetime "stop_delivering_at", precision: nil
    t.text "title"
    t.datetime "updated_at", precision: nil
  end

  create_table "transfer_request_urls", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "transfer_request_id"
    t.integer "url_id"
    t.index ["transfer_request_id"], name: "index_transfer_request_urls_on_transfer_request_id"
    t.index ["url_id"], name: "index_transfer_request_urls_on_url_id"
  end

  create_table "transfer_requests", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "from_group_id"
    t.integer "from_group_requestor_id"
    t.string "key"
    t.string "status", default: "pending"
    t.integer "to_group_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["from_group_id"], name: "index_transfer_requests_on_from_group_id"
    t.index ["to_group_id"], name: "index_transfer_requests_on_to_group_id"
  end

  create_table "urls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "group_id"
    t.string "keyword"
    t.integer "modified_by"
    t.text "note"
    t.integer "total_clicks", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.text "url"
    t.index ["group_id"], name: "index_urls_on_group_id"
    t.index ["keyword"], name: "index_urls_on_keyword", unique: true
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "admin"
    t.integer "context_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "default_group_id"
    t.string "remember_token"
    t.string "secret_key"
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["context_group_id"], name: "index_users_on_context_group_id"
    t.index ["default_group_id"], name: "index_users_on_default_group_id"
  end

  create_table "versions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type"
    t.text "object", size: :long
    t.text "version_history"
    t.string "whodunnit"
    t.string "whodunnit_email"
    t.string "whodunnit_name"
    t.string "{:null=>false, :limit=>191}"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "clicks", "urls"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "transfer_request_urls", "transfer_requests"
  add_foreign_key "transfer_request_urls", "urls"
  add_foreign_key "transfer_requests", "groups", column: "from_group_id"
  add_foreign_key "transfer_requests", "groups", column: "to_group_id"
  add_foreign_key "urls", "groups"
  add_foreign_key "users", "groups", column: "context_group_id"
  add_foreign_key "users", "groups", column: "default_group_id"
end
