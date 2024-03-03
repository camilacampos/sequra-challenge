require "rails_helper"

RSpec.describe ::CalculateCommission do
  context "when disbursement already exists" do
    it "creates commission for existing disbursement" do
      merchant = create(:merchant, :daily)
      created_at = Date.parse("2024-02-02")
      order = create(:order, merchant:, created_at:)
      disbursement = create(:disbursement, :pending,
        merchant:, commissions: [], reference_date: order.created_at.to_date)

      described_class.new.call(order:)

      disbursement.reload
      commissions = disbursement.commissions
      expect(disbursement).to be_processing
      expect(commissions.count).to eq(1)
      expect(commissions.first.order).to eq(order)
    end

    it "updates disbursement totals with commission values" do
      merchant = create(:merchant, :daily)
      created_at = Date.parse("2024-02-02")
      order = create(:order, merchant:, created_at:)
      disbursement = create(:disbursement, :pending,
        merchant:, commissions: [], reference_date: order.created_at.to_date,
        total_commission_fee: 0, total_amount: 0, disbursed_amount: 0)

      described_class.new.call(order:)

      disbursement.reload
      commission = disbursement.commissions.first
      expect(disbursement).to be_processing
      expect(disbursement.total_commission_fee).to eq(commission.fee_value)
      expect(disbursement.total_amount).to eq(order.amount)
      expect(disbursement.disbursed_amount).to eq(commission.disbursed_amount)
    end

    context "when creating commission fails" do
      it "does not create commission and dont update disbursement" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :pending,
          merchant:, commissions: [], reference_date: order.created_at.to_date,
          total_commission_fee: 0, total_amount: 0, disbursed_amount: 0)

        allow(Commission).to receive(:create!).and_raise("some error")

        expect {
          described_class.new.call(order:)
        }.to raise_error("some error")

        disbursement.reload
        expect(disbursement).to be_pending
        expect(disbursement.commissions).to be_empty
        expect(disbursement.total_commission_fee).to eq(0)
        expect(disbursement.total_amount).to eq(0)
        expect(disbursement.disbursed_amount).to eq(0)
      end
    end
  end

  context "when disbursement does not exist" do
    it "creates commission for new disbursement" do
      merchant = create(:merchant, :daily)
      created_at = Date.parse("2024-02-02")
      order = create(:order, merchant:, created_at:)

      described_class.new.call(order:)

      order.reload
      disbursement = Disbursement.last
      expect(disbursement).to be_processing
      expect(disbursement.commissions).to contain_exactly(order.commission)
    end

    it "updates new disbursement with totals from commission values" do
      merchant = create(:merchant, :daily)
      created_at = Date.parse("2024-02-02")
      order = create(:order, merchant:, created_at:)

      described_class.new.call(order:)

      order.reload
      commission = order.commission
      disbursement = commission.disbursement
      expect(disbursement).to be_processing
      expect(disbursement.total_commission_fee).to eq(commission.fee_value)
      expect(disbursement.total_amount).to eq(order.amount)
      expect(disbursement.disbursed_amount).to eq(commission.disbursed_amount)
    end

    context "when creating disbursement fails" do
      it "does not create commission" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)

        allow(Disbursement).to receive(:create!).and_raise("some error")

        expect {
          described_class.new.call(order:)
        }.to raise_error("some error")

        order.reload
        expect(order.commission).to be_nil
        expect(Disbursement.count).to eq(0)
      end
    end

    context "when creating commission fails" do
      it "does not create disbursement nor commission" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)

        allow(Commission).to receive(:create!).and_raise("some error")

        expect {
          described_class.new.call(order:)
        }.to raise_error("some error")

        expect(Disbursement.count).to eq(0)
        expect(Commission.count).to eq(0)
      end
    end
  end
end
