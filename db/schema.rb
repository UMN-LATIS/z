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

ActiveRecord::Schema.define(version: 20160524143354) do

  create_table "clicks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "referrer"
    t.string   "user_agent"
    t.string   "ip_address"
    t.string   "country_code"
    t.integer  "url_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["url_id"], name: "index_clicks_on_url_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "groups_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id", using: :btree
    t.index ["user_id"], name: "index_groups_users_on_user_id", using: :btree
  end

  create_table "site_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "next_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfer_request_urls", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "transfer_request_id"
    t.integer "url_id"
    t.index ["transfer_request_id"], name: "index_transfer_request_urls_on_transfer_request_id", using: :btree
    t.index ["url_id"], name: "index_transfer_request_urls_on_url_id", using: :btree
  end

  create_table "transfer_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "to_group_id"
    t.integer  "from_group_id"
    t.string   "key"
    t.string   "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "urls", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "url"
    t.string   "keyword"
    t.integer  "clicks"
    t.integer  "group_id"
    t.integer  "modified_by"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id"], name: "index_urls_on_group_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "email"
    t.integer  "context_group_id"
    t.boolean  "admin"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_foreign_key "clicks", "urls"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "transfer_request_urls", "transfer_requests"
  add_foreign_key "transfer_request_urls", "urls"
  add_foreign_key "urls", "groups"
end
