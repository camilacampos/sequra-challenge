FactoryBot.define do
  factory :merchant do
    reference { SecureRandom.hex(10) }
    email { reference + "@example.com" }
    live_on { Date.today }
    disbursement_frequency { ::Enum::DisbursementFrequencies::DAILY }
    minimum_monthly_fee { Money.from_amount(100) }

    trait :daily do
      disbursement_frequency { ::Enum::DisbursementFrequencies::DAILY }
    end

    trait :weekly do
      disbursement_frequency { ::Enum::DisbursementFrequencies::WEEKLY }
    end

    trait :with_orders do
      transient do
        orders_count { 5 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:order, evaluator.orders_count, merchant: merchant)
      end
    end
  end
end
