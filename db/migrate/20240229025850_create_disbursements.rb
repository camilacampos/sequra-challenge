class CreateDisbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :disbursements, id: :uuid do |t|
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.string :reference, null: false
      t.string :status, null: false

      t.monetize :total_commission_fee
      t.monetize :total_amount
      t.monetize :disbursed_amount

      t.monetize :monthly_fee,
        amount: {null: true, default: nil},
        currency: {null: true, default: nil}

      t.string :frequency, null: false
      t.date :reference_date, null: false
      t.datetime :calculated_at, null: true

      t.timestamps
    end
  end
end
