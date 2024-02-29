FactoryBot.define do
  factory :commission do
    order_amount { Money.from_amount(100) }
    fee_percentage { 0.01 }
    fee_value { order_amount * fee_percentage }
    disbursed_amount { order_amount - fee_value }

    order { create(:order) }
    disbursement { create(:disbursement) }
  end
end
