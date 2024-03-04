require "rails_helper"

RSpec.describe ::FinishDisbursementCalculation do
  context "when disbursement is the first of the month" do
    it "changes disbursement status to 'calculated'" do
      reference_date = Date.today.beginning_of_month

      merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
      _last_month_disbursement1 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(50))
      _last_month_disbursement2 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(60))

      disbursement = create(:disbursement, :processing, reference_date:, merchant:)

      described_class.new.call(disbursement)

      disbursement.reload
      expect(disbursement).to be_calculated
      expect(disbursement.calculated_at).to be_within(1.minute).of(Time.zone.now)
    end

    context "when past month commissions are greater than merchant's minimum monthly fee" do
      it "does not calculate monthly fee" do
        reference_date = Date.today.beginning_of_month

        merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
        _last_month_disbursement1 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(50))
        _last_month_disbursement2 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(60))

        disbursement = create(:disbursement, :processing, reference_date:, merchant:)

        described_class.new.call(disbursement)

        disbursement.reload
        expect(disbursement.monthly_fee).to eq(Money.from_amount(0))
      end
    end

    context "when past month commissions are equal to merchant's minimum monthly fee" do
      it "does not calculate monthly fee" do
        reference_date = Date.today.beginning_of_month

        merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
        _last_month_disbursement1 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(50))
        _last_month_disbursement2 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(50))

        disbursement = create(:disbursement, :processing, reference_date:, merchant:)

        described_class.new.call(disbursement)

        disbursement.reload
        expect(disbursement.monthly_fee).to eq(Money.from_amount(0))
      end
    end

    context "when past month commissions are less than merchant's minimum monthly fee" do
      it "calculates monthly fee" do
        reference_date = Date.today.beginning_of_month

        merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
        _last_month_disbursement1 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(20))
        _last_month_disbursement2 = create(:disbursement, :calculated,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(35))
        _not_calculated_disbursement = create(:disbursement, :processing,
          merchant:, reference_date: reference_date.prev_month,
          total_commission_fee: Money.from_amount(30))
        _other_merchant_disbursement = create(:disbursement, :calculated,
          total_commission_fee: Money.from_amount(100))

        disbursement = create(:disbursement, :processing, reference_date:, merchant:)

        described_class.new.call(disbursement)

        disbursement.reload
        expect(disbursement.monthly_fee).to eq(Money.from_amount(45))
      end
    end
  end

  context "when disbursement is not the first of the month" do
    it "changes disbursement status to 'calculated'" do
      reference_date = Date.today.beginning_of_month + 1.week

      merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
      _last_month_disbursement1 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(20))
      _last_month_disbursement2 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(10))

      disbursement = create(:disbursement, :processing, reference_date:, merchant:)

      described_class.new.call(disbursement)

      disbursement.reload
      expect(disbursement).to be_calculated
      expect(disbursement.calculated_at).to be_within(1.minute).of(Time.zone.now)
    end

    it "does not calculate monthly fee" do
      reference_date = Date.today.beginning_of_month + 1.week

      merchant = create(:merchant, minimum_monthly_fee: Money.from_amount(100))
      _last_month_disbursement1 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(20))
      _last_month_disbursement2 = create(:disbursement, :calculated,
        merchant:, reference_date: reference_date.prev_month,
        total_commission_fee: Money.from_amount(10))

      disbursement = create(:disbursement, :processing, reference_date:, merchant:)

      described_class.new.call(disbursement)

      disbursement.reload
      expect(disbursement.monthly_fee).to eq(Money.from_amount(0))
    end
  end
end
