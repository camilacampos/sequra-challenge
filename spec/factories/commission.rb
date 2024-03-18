FactoryBot.define do
  factory :commission do
    order_amount { Money.from_amount(100) }
    fee_percentage { 0.01 }
    fee_value { order_amount * fee_percentage }
    disbursed_amount { order_amount - fee_value }

    transient do
      merchant { create(:merchant) }
    end

    order { create(:order, merchant:) }
    disbursement { create(:disbursement) }
  end
end
