require "rails_helper"

RSpec.describe ::RequestRefund do
  include ActiveSupport::Testing::TimeHelpers

  context "when requesting a refund" do
    context "when disbusement is not closed" do
      context "when merchant disbursement frequency is daily" do
        it "deducts the amount from the disbursement at the refund date" do
          merchant = create(:merchant, :daily)
          disbursement = create(:disbursement, :processing, :with_commissions,
            merchant:, reference_date: Date.parse("2024-02-02"))
          order = disbursement.commissions.first.order
          refund = double(:refund, order_id: order.id, amount: order.amount, date: Date.parse("2024-02-02"))
          refund_class = double(:refund_class, create!: refund)

          expect {
            described_class.new.call(
              order_id: refund.order_id,
              amount: refund.amount,
              date: refund.date,
              refund_class:
            )
          }.to change { disbursement.reload.disbursed_amount }.by(-refund.amount)
            .and change { disbursement.reload.total_amount }.by(-refund.amount)
        end
      end

      context "when merchant disbursement frequency is weekly" do
      end
    end

    context "when the disbusment is closed" do
      context "when merchant disbursement frequency is daily" do
      end

      context "when merchant disbursement frequency is weekly" do
      end
    end
  end
end
