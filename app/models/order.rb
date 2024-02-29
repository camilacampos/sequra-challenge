class Order < ApplicationRecord
  attribute :reference, :string
  monetize :amount_cents

  belongs_to :merchant

  validates_uniqueness_of :reference
end
