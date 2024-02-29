class Disbursement < ApplicationRecord
  # Unique reference for the disbursement
  attribute :reference, :string, default: -> { SecureRandom.uuid }

  # Status of the disbursement
  # PENDING: Disbursement was just created and have no orders associated yet
  # PROCESSING: Orders are being added to the disbursement
  # CALCULATED: Disbursement is ready to be disbursed
  enum :status, ::Enum::DisbursementStatuses.to_h, default: ::Enum::DisbursementStatuses::PENDING

  # Total amount of commission fees that the merchant has to pay
  # Sum of all commissions fee values
  monetize :total_commission_fee_cents

  # Total amount of money that the merchant selled on their orders
  # Sum of all orders amount
  monetize :total_amount_cents

  # Total amount of money that the merchant will receive (total_amount - total_commission_fee)
  # Sum of all commissions disbursed amount
  monetize :disbursed_amount_cents

  # Monthly fee that the merchant has to pay if minimun_monthly_fee is not reached
  # Filled only for first disbursement of the month
  monetize :monthly_fee_cents, allow_nil: true

  # Frequency in which the disbursement will be calculated (from merchant)
  enum :frequency, ::Enum::DisbursementFrequencies.to_h

  # Date that the disbursement is referring to
  # If frequency is daily, it will be the date of the disbursement
  # If frequency is weekly, it will be the first day of the week in which the disbursement is referring to
  attribute :reference_date, :date

  # Timestamp of when the disbursement was calculated
  attribute :calculated_at, :datetime

  belongs_to :merchant
  has_many :commissions

  validates :merchant, :reference, :status, :frequency, :reference_date, presence: true
  validates :calculated_at, presence: true, if: -> { calculated? }
  validates_uniqueness_of :reference
end
