class OrdersTmp < ActiveRecord::Migration[7.1]
  def change
    create_table :orders_tmp, id: :string do |t|
      t.string :merchant_reference, null: false
      t.string :amount, null: false
      t.string :created_at, null: false
    end
  end
end
