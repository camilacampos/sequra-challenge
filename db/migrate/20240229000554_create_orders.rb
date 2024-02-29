class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.string :reference, null: false
      t.monetize :amount
      t.references :merchant, null: false, foreign_key: true, type: :uuid

      t.timestamps

      t.index :reference, unique: true
    end
  end
end
