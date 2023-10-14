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

ActiveRecord::Schema[7.0].define(version: 2023_10_13_183730) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "disbursements", force: :cascade do |t|
    t.string "reference"
    t.integer "order_fee_amount_cents"
    t.integer "amount_cents"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchants", force: :cascade do |t|
    t.string "reference"
    t.string "email"
    t.date "live_on"
    t.string "disbursement_frequency"
    t.integer "minimum_monthly_fee_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_commissions", force: :cascade do |t|
    t.integer "order_amount_cents"
    t.integer "sequra_amount_cents"
    t.integer "merchant_amount_cents"
    t.decimal "fee_percentage"
    t.date "order_date"
    t.bigint "order_id", null: false
    t.bigint "disbursement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disbursement_id"], name: "index_order_commissions_on_disbursement_id"
    t.index ["order_id"], name: "index_order_commissions_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "merchant_reference"
    t.integer "amount_cents"
    t.string "currency"
    t.string "disbursement_reference"
    t.bigint "disbursement_id", null: false
    t.bigint "merchant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disbursement_id"], name: "index_orders_on_disbursement_id"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["merchant_reference"], name: "index_orders_on_merchant_reference"
  end

  add_foreign_key "order_commissions", "disbursements"
  add_foreign_key "order_commissions", "orders"
  add_foreign_key "orders", "disbursements"
  add_foreign_key "orders", "merchants"
end
