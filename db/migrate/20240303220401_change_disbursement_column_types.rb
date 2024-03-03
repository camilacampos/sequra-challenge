class ChangeDisbursementColumnTypes < ActiveRecord::Migration[7.1]
  def change
    change_column :disbursements, :total_commission_fee_cents, :integer, limit: 8
    change_column :disbursements, :total_amount_cents, :integer, limit: 8
    change_column :disbursements, :disbursed_amount_cents, :integer, limit: 8
  end
end
