FactoryBot.define do
  factory :disbursement do
    reference { SecureRandom.hex(10) }
    status { ::Enum::DisbursementStatuses::PROCESSING }

    total_commission_fee { Money.from_amount(100) }
    total_amount { Money.from_amount(100) }
    disbursed_amount { Money.from_amount(100) }
    monthly_fee { Money.from_amount(100) }

    frequency { ::Enum::DisbursementFrequencies::DAILY }
    reference_date { Date.today }
    calculated_at { nil }

    merchant { create(:merchant) }

    trait :daily do
      frequency { ::Enum::DisbursementFrequencies::DAILY }
    end

    trait :weekly do
      frequency { ::Enum::DisbursementFrequencies::WEEKLY }
    end

    trait :pending do
      status { ::Enum::DisbursementStatuses::PENDING }
    end

    trait :processing do
      status { ::Enum::DisbursementStatuses::PROCESSING }
    end

    trait :calculated do
      status { ::Enum::DisbursementStatuses::CALCULATED }
      calculated_at { Time.current }
    end

    trait :with_commissions do
      transient do
        commissions_count { 5 }
      end

      after(:create) do |disbursement, evaluator|
        create_list(:commission, evaluator.commissions_count, disbursement:, merchant: disbursement.merchant)
      end
    end
  end
end
