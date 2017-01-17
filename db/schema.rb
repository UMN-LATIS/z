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

ActiveRecord::Schema.define(version: 20170117151420) do

  create_table "clicks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "groups_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "notify_user_changes", default: false, null: false
    t.index ["group_id"], name: "index_groups_users_on_group_id", using: :btree
    t.index ["user_id"], name: "index_groups_users_on_user_id", using: :btree
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
    t.integer  "from_group_requestor_id"
    t.string   "key"
    t.string   "status"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["from_group_id"], name: "index_transfer_requests_on_from_group_id", using: :btree
    t.index ["to_group_id"], name: "index_transfer_requests_on_to_group_id", using: :btree
  end

  create_table "umn_departments", primary_key: "DEPTID", id: :string, limit: 11, default: "", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=1 ROW_FORMAT=DYNAMIC" do |t|
    t.string  "DESCR",                          limit: 31,  default: "",    null: false
    t.string  "UM_VP",                          limit: 11,  default: "",    null: false
    t.string  "UM_VP_DESCR",                    limit: 31,  default: "",    null: false
    t.string  "UM_CAMPUS",                      limit: 11,  default: "",    null: false
    t.string  "UM_CAMPUS_DESCR",                limit: 31,  default: "",    null: false
    t.string  "UM_COLLEGE",                     limit: 11,  default: "",    null: false
    t.string  "UM_COLLEGE_DESCR",               limit: 31,  default: "",    null: false
    t.string  "UM_ZDEPTID",                     limit: 11,  default: "",    null: false
    t.string  "UM_ZDEPTID_DESCR",               limit: 31,  default: "",    null: false
    t.integer "technician_emplid"
    t.string  "technician_internet_id",         limit: 100
    t.string  "technician_name",                limit: 100
    t.string  "technician_email",               limit: 100
    t.string  "technician_phone",               limit: 20
    t.integer "chair_emplid"
    t.integer "admin_emplid"
    t.integer "accountant_emplid"
    t.string  "phone",                          limit: 20
    t.string  "email",                          limit: 100
    t.string  "display_name",                               default: "",    null: false
    t.string  "site_url",                                   default: "",    null: false
    t.string  "location_link_text",                         default: "",    null: false
    t.string  "location_link_url",                          default: "",    null: false
    t.string  "building_name",                                              null: false
    t.string  "building_number",                limit: 20,  default: "",    null: false
    t.string  "ad_ou",                          limit: 10,  default: "",    null: false
    t.boolean "is_research_center",                         default: false
    t.boolean "is_main_dept_for_um_entity",                 default: false
    t.boolean "is_college_office",                          default: false
    t.boolean "hide_from_cla_directory",                    default: false
    t.string  "cache_auxiliary_full_text_data", limit: 100
    t.index ["DEPTID", "DESCR", "UM_VP_DESCR", "UM_CAMPUS_DESCR", "UM_COLLEGE_DESCR", "UM_ZDEPTID_DESCR", "phone", "email", "site_url", "location_link_text", "ad_ou", "cache_auxiliary_full_text_data"], name: "autocompleter_full_text_index", type: :fulltext
    t.index ["UM_CAMPUS"], name: "UM_CAMPUS", using: :btree
    t.index ["UM_COLLEGE"], name: "UM_COLLEGE", using: :btree
    t.index ["UM_ZDEPTID"], name: "UM_ZDEPTID", using: :btree
    t.index ["accountant_emplid"], name: "accountant_emplid", using: :btree
    t.index ["ad_ou"], name: "ad_ou", using: :btree
    t.index ["admin_emplid"], name: "admin_emplid", using: :btree
    t.index ["chair_emplid"], name: "chair_emplid", using: :btree
    t.index ["hide_from_cla_directory"], name: "hide_from_cla_directory", using: :btree
    t.index ["is_college_office"], name: "is_college_office", using: :btree
    t.index ["is_main_dept_for_um_entity"], name: "is_main_dept_for_um_entity", using: :btree
    t.index ["is_research_center"], name: "is_research_center", using: :btree
    t.index ["technician_emplid"], name: "technician_emplid", using: :btree
  end

  create_table "urls", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "url"
    t.string   "keyword"
    t.integer  "total_clicks"
    t.integer  "group_id"
    t.integer  "modified_by"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["group_id"], name: "index_urls_on_group_id", using: :btree
    t.index ["keyword"], name: "index_urls_on_keyword", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uid"
    t.integer  "context_group_id"
    t.integer  "default_group_id"
    t.boolean  "admin"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "remember_token"
    t.index ["context_group_id"], name: "index_users_on_context_group_id", using: :btree
    t.index ["default_group_id"], name: "index_users_on_default_group_id", using: :btree
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
