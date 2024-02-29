class CreateCommissions < ActiveRecord::Migration[7.1]
  def change
    create_table :commissions, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :disbursement, null: false, foreign_key: true, type: :uuid

      t.monetize :order_amount
      t.float :fee_percentage, null: false
      t.monetize :fee_value
      t.monetize :disbursed_amount

      t.timestamps
    end
  end
end
