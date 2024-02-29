require "rails_helper"

RSpec.describe ::FindOrCreateDisbursement do
  include ActiveSupport::Testing::TimeHelpers

  context "when disbursement exists" do
    context "when existing disbursement is pending" do
      it "uses found disbursement" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :pending, merchant:, reference_date: order.created_at.to_date)

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.not_to change(Disbursement, :count)

        expect(found_disbursement).to eq disbursement
      end
    end

    context "when existing disbursement is processing" do
      it "uses found disbursement" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :processing, merchant:, reference_date: order.created_at.to_date)

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.not_to change(Disbursement, :count)

        expect(found_disbursement).to eq disbursement
      end
    end

    context "when existing disbursement is calculated" do
      it "creates new disbursement" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :calculated, merchant:, reference_date: order.created_at.to_date)

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.to change(Disbursement, :count).by(1)

        expect(found_disbursement).not_to eq disbursement
      end
    end
  end

  context "when disbursement is found" do
    context "when merchant disbursement frequency is daily" do
      it "returns disbursement found on the order created_at date" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :pending, merchant:, reference_date: order.created_at.to_date)

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.not_to change(Disbursement, :count)

        expect(found_disbursement).to eq disbursement
      end
    end

    context "when merchant disbursement frequency is weekly" do
      it "returns disbursement found on the latest day before order created at on the merchant's live_on weekday as reference date" do
        # today = wednesday
        travel_to Date.today.next_occurring(:wednesday)

        live_on = Date.today - 4.weeks # wednesday
        merchant = create(:merchant, :weekly, live_on:)

        created_at = Date.today + 2.days # next friday
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :pending, merchant:, reference_date: Date.today) # wednesday

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.not_to change(Disbursement, :count)

        expect(found_disbursement).to eq disbursement

        travel_back
      end

      it "returns disbursement found on the order created_at date if merchant's live_on weekday is the same as order created_at" do
        # today = wednesday
        travel_to Date.today.next_occurring(:wednesday)

        live_on = Date.today - 4.weeks # wednesday
        merchant = create(:merchant, :weekly, live_on:)

        created_at = Date.today + 1.week # next wednesday
        order = create(:order, merchant:, created_at:)
        disbursement = create(:disbursement, :pending, merchant:, reference_date: order.created_at.to_date)

        found_disbursement = nil

        expect {
          found_disbursement = described_class.new.call(order)
        }.not_to change(Disbursement, :count)

        expect(found_disbursement).to eq disbursement

        travel_back
      end
    end
  end

  context "when disbursement is not found" do
    context "when merchant disbursement frequency is daily" do
      it "creates disbursement with order created at as reference date" do
        merchant = create(:merchant, :daily)
        created_at = Date.parse("2024-02-02")
        order = create(:order, merchant:, created_at:)

        disbursement = nil

        expect {
          disbursement = described_class.new.call(order)
        }.to change(Disbursement, :count).by(1)

        expect(disbursement.reference).to be_present
        expect(disbursement).to be_pending
        expect(disbursement.frequency).to eq merchant.disbursement_frequency
        expect(disbursement.reference_date).to eq created_at
        expect(disbursement.calculated_at).to be_nil
        expect(disbursement.merchant).to eq merchant
      end
    end

    context "when merchant disbursement frequency is weekly" do
      it "creates disbursement with latest day before order created at on the merchant's live_on weekday as reference date" do
        # today = wednesday
        travel_to Date.today.next_occurring(:wednesday)

        live_on = Date.today - 4.weeks # wednesday
        merchant = create(:merchant, :weekly, live_on:)

        created_at = Date.today + 2.days # next friday
        order = create(:order, merchant:, created_at:)

        disbursement = nil

        expect {
          disbursement = described_class.new.call(order)
        }.to change(Disbursement, :count).by(1)

        expect(disbursement.reference).to be_present
        expect(disbursement).to be_pending
        expect(disbursement.frequency).to eq merchant.disbursement_frequency
        expect(disbursement.reference_date).to eq Date.today # this wednesday
        expect(disbursement.calculated_at).to be_nil
        expect(disbursement.merchant).to eq merchant

        travel_back
      end

      it "creates disbursement with order created at as reference date if merchant's live_on weekday is the same as order created_at" do
        # today = wednesday
        travel_to Date.today.next_occurring(:wednesday)

        live_on = Date.today - 4.weeks # wednesday
        merchant = create(:merchant, :weekly, live_on:)

        created_at = Date.today + 1.week # next wednesday
        order = create(:order, merchant:, created_at:)

        disbursement = nil

        expect {
          disbursement = described_class.new.call(order)
        }.to change(Disbursement, :count).by(1)

        expect(disbursement.reference).to be_present
        expect(disbursement).to be_pending
        expect(disbursement.frequency).to eq merchant.disbursement_frequency
        expect(disbursement.reference_date).to eq order.created_at.to_date
        expect(disbursement.calculated_at).to be_nil
        expect(disbursement.merchant).to eq merchant

        travel_back
      end
    end
  end
end
