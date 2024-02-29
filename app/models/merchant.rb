class Merchant < ApplicationRecord
  attribute :reference, :string
  attribute :email, :string
  attribute :live_on, :date
  enum :disbursement_frequency, ::Enum::DisbursementFrequencies.to_h
  monetize :minimum_monthly_fee_cents

  has_many :orders

  validates :reference, :email, :live_on, :disbursement_frequency, :minimum_monthly_fee, presence: true
  validates_uniqueness_of :reference, :email
end
