require "rails_helper"

RSpec.describe FinishDisbursementsCalculationJob, type: :job do
  it "calculates commissions for disbursements with today as reference date" do
    disbursement1 = create(:disbursement, :daily, :processing, reference_date: Date.today)
    disbursement2 = create(:disbursement, :weekly, :processing, reference_date: Date.today)
    other_disbursement = create(:disbursement, :daily, :processing, reference_date: Date.yesterday)

    described_class.new.perform

    disbursement1.reload
    disbursement2.reload
    other_disbursement.reload
    expect(disbursement1).to be_calculated
    expect(disbursement2).to be_calculated
    expect(other_disbursement).to be_processing
  end
end
