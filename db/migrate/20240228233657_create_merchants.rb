class CreateMerchants < ActiveRecord::Migration[7.1]
  def change
    create_table :merchants, id: :uuid do |t|
      t.string :reference, null: false
      t.string :email, null: false
      t.date :live_on, null: false
      t.string :disbursement_frequency, null: false, default: "weekly"
      t.monetize :minimum_monthly_fee

      t.timestamps

      t.index :reference, unique: true
      t.index :email, unique: true
    end
  end
end
