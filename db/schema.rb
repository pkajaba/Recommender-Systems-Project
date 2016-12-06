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

ActiveRecord::Schema.define(version: 20161206115237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jokes", force: :cascade do |t|
    t.text     "content"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_jokes_on_category_id", using: :btree
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "joke_id"
    t.integer  "user_id"
    t.integer  "user_rating"
    t.integer  "suggested_rating"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["joke_id"], name: "index_ratings_on_joke_id", using: :btree
    t.index ["user_id"], name: "index_ratings_on_user_id", using: :btree
  end

  create_table "user_prefer_categories", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "total_rated_jokes", default: 0
    t.integer  "total_rate",        default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["category_id"], name: "index_user_prefer_categories_on_category_id", using: :btree
    t.index ["user_id"], name: "index_user_prefer_categories_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "strategy",         default: 0
  end

  add_foreign_key "jokes", "categories"
  add_foreign_key "ratings", "jokes"
  add_foreign_key "ratings", "users"
  add_foreign_key "user_prefer_categories", "categories"
  add_foreign_key "user_prefer_categories", "users"
end
