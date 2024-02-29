require "rails_helper"

RSpec.describe ::CreateCommission do
  context "when any attribute is invalid" do
    it "raises an error" do
      fee = Fee.new(percentage: 30 / 100.0, from_amount: Money.from_amount(100))

      expect {
        described_class.new.call(
          disbursement: nil, order: nil, fee:
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "when all attributes are valid" do
    it "creates commission" do
      disbursement = create(:disbursement)
      order = create(:order)
      fee = Fee.new(percentage: 30 / 100.0, from_amount: Money.from_amount(100))

      commission = described_class.new.call(
        disbursement:, order:, fee:
      )

      expect(commission).to be_persisted
      expect(commission.order).to eq order
      expect(commission.disbursement).to eq disbursement
      expect(commission.order_amount).to eq order.amount
      expect(commission.fee_percentage).to eq fee.percentage
      expect(commission.fee_value).to eq fee.value
      expect(commission.disbursed_amount).to eq fee.disbursed_amount
    end
  end
end
