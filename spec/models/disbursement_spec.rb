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
end
