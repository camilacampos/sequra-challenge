class Order < ApplicationRecord
  attribute :reference, :string
  monetize :amount_cents

  belongs_to :merchant

  validates :reference, presence: true, uniqueness: true
end
