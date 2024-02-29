FactoryBot.define do
  factory :order do
    reference { SecureRandom.hex(10) }
    amount { Money.from_amount(100) }
    merchant { create(:merchant) }
  end
end
