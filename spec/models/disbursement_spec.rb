require "rails_helper"

RSpec.describe Disbursement do
  context "when retrieving pending or processing disbursements" do
    it "returns disbursements with status pending or processing" do
      pending = create(:disbursement, :pending)
      processing = create(:disbursement, :processing)
      _calculated = create(:disbursement, :calculated)

      expect(Disbursement.pending_or_processing).to contain_exactly(pending, processing)
    end
  end

  context "when retrieving disbursements by month" do
    it "returns disbursements within the month" do
      this_month = Date.today
      disbursement = create(:disbursement, reference_date: this_month)
      _other_disbursement = create(:disbursement, reference_date: this_month.next_month)

      expect(Disbursement.by_month(this_month)).to contain_exactly(disbursement)
    end
  end

  context "when retrieving disbursements by merchant" do
    it "returns disbursements for the merchant" do
      merchant = create(:merchant)
      disbursement = create(:disbursement, merchant:)
      _other_disbursement = create(:disbursement, merchant: create(:merchant))

      expect(Disbursement.by_merchant(merchant)).to contain_exactly(disbursement)
    end
  end

  context "when checking if disbursement is the first of the month" do
    it "returns true if reference date is the first day of the month" do
      disbursement = build(:disbursement, reference_date: "2024-02-01")

      expect(disbursement).to be_first_of_the_month
    end

    it "returns false if reference date is not the first day of the month" do
      disbursement = build(:disbursement, reference_date: "2024-02-02")

      expect(disbursement).not_to be_first_of_the_month
    end
  end

  context "when updating totals from commission" do
    it "raises error if disbursement is already calculated" do
      disbursement = create(:disbursement, :calculated)
      commission = create(:commission)

      expect {
        disbursement.update_totals_from!(commission)
      }.to raise_error("Disbursement already calculated")
    end

    it "adds commission to disbursement and updates totals" do
      total_commission_fee = Money.from_amount(30)
      total_amount = Money.from_amount(200)
      disbursed_amount = Money.from_amount(170)
      disbursement = create(:disbursement, :pending,
        total_commission_fee:, total_amount:, disbursed_amount:)

      fee_value = Money.from_amount(50)
      order_amount = Money.from_amount(400)
      commission_disbursed_amount = Money.from_amount(350)
      commission = create(:commission, disbursement:,
        fee_value:, order_amount:, disbursed_amount: commission_disbursed_amount)

      disbursement.update_totals_from!(commission)

      expect(disbursement).to be_processing
      expect(disbursement.commissions).to contain_exactly(commission)
      expect(disbursement.total_commission_fee).to eq(total_commission_fee + fee_value)
      expect(disbursement.total_amount).to eq(total_amount + order_amount)
      expect(disbursement.disbursed_amount).to eq(disbursed_amount + commission_disbursed_amount)
    end
  end
end
