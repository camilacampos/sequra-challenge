class Commission < ApplicationRecord
  # Order amount (from order)
  monetize :order_amount_cents

  # Fee percentage that the merchant has to pay (based on order amount)
  attribute :fee_percentage, :float

  # Fee value that the merchant has to pay (fee_percentage * order_amount)
  monetize :fee_value_cents

  # Amount that the merchant will receive (order_amount - fee_value)
  monetize :disbursed_amount_cents

  belongs_to :order
  belongs_to :disbursement

  validates :fee_percentage, presence: true
end
