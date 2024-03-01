class Order < ApplicationRecord
  attribute :reference, :string
  monetize :amount_cents

  belongs_to :merchant
  has_many :commissions

  validates :reference, presence: true, uniqueness: true
end
