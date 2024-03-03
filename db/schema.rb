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

ActiveRecord::Schema[7.1].define(version: 2024_03_03_220401) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "commissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "disbursement_id", null: false
    t.integer "order_amount_cents", default: 0, null: false
    t.string "order_amount_currency", default: "EUR", null: false
    t.float "fee_percentage", null: false
    t.integer "fee_value_cents", default: 0, null: false
    t.string "fee_value_currency", default: "EUR", null: false
    t.integer "disbursed_amount_cents", default: 0, null: false
    t.string "disbursed_amount_currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disbursement_id"], name: "index_commissions_on_disbursement_id"
    t.index ["order_id"], name: "index_commissions_on_order_id"
  end

  create_table "disbursements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "merchant_id", null: false
    t.string "reference", null: false
    t.string "status", null: false
    t.bigint "total_commission_fee_cents", default: 0, null: false
    t.string "total_commission_fee_currency", default: "EUR", null: false
    t.bigint "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "EUR", null: false
    t.bigint "disbursed_amount_cents", default: 0, null: false
    t.string "disbursed_amount_currency", default: "EUR", null: false
    t.integer "monthly_fee_cents"
    t.string "monthly_fee_currency"
    t.string "frequency", null: false
    t.date "reference_date", null: false
    t.datetime "calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_disbursements_on_merchant_id"
  end

  create_table "merchants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", null: false
    t.string "email", null: false
    t.date "live_on", null: false
    t.string "disbursement_frequency", default: "weekly", null: false
    t.integer "minimum_monthly_fee_cents", default: 0, null: false
    t.string "minimum_monthly_fee_currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["reference"], name: "index_merchants_on_reference", unique: true
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.uuid "merchant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
  end

  create_table "orders_tmp", id: :string, force: :cascade do |t|
    t.string "merchant_reference", null: false
    t.string "amount", null: false
    t.string "created_at", null: false
  end

  add_foreign_key "commissions", "disbursements"
  add_foreign_key "commissions", "orders"
  add_foreign_key "disbursements", "merchants"
  add_foreign_key "orders", "merchants"
end
