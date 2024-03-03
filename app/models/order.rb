class Order < ApplicationRecord
  attribute :reference, :string
  monetize :amount_cents

  belongs_to :merchant
  has_one :commission

  validates :reference, presence: true, uniqueness: true
end
