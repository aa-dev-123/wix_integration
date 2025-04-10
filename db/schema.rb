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

ActiveRecord::Schema.define(version: 2025_04_10_201402) do

  create_table "authentications", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uid"
    t.datetime "token_expires_at"
    t.index ["uid"], name: "index_authentications_on_uid", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.string "external_reference_id"
    t.string "subtotal"
    t.integer "shipping"
    t.string "tax"
    t.string "discount"
    t.string "total"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "price"
    t.string "currency"
    t.string "product_type"
    t.string "sku"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "external_shop_id"
    t.integer "authentication_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["authentication_id"], name: "index_shops_on_authentication_id"
  end

  add_foreign_key "shops", "authentications"
end
