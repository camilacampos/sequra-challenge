require "rails_helper"

RSpec.describe ::CreateMerchant do
  context "when any attribute is invalid" do
    it "raises an error" do
      expect {
        described_class.new.call(
          reference: nil,
          email: nil,
          live_on: nil,
          disbursement_frequency: nil,
          minimum_monthly_fee: nil
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "when all attributes are valid" do
    context "when id is not provided" do
      it "creates merchant generating a new ID" do
        reference = "merchant-reference"
        email = "some@email.com"
        live_on = Date.today
        disbursement_frequency = ::Enum::DisbursementFrequencies::DAILY
        minimum_monthly_fee = Money.from_amount(100)

        merchant = described_class.new.call(
          reference:, email:, live_on:,
          disbursement_frequency:,
          minimum_monthly_fee:
        )

        expect(merchant).to be_persisted
        expect(merchant.reference).to eq reference
        expect(merchant.email).to eq email
        expect(merchant.live_on).to eq live_on
        expect(merchant.disbursement_frequency).to eq disbursement_frequency
        expect(merchant.minimum_monthly_fee).to eq minimum_monthly_fee
        expect(merchant.id).to be_present
      end
    end

    context "when id is provided" do
      it "creates merchant with the provided ID" do
        id = SecureRandom.uuid
        reference = "merchant-reference"
        email = "some@email.com"
        live_on = Date.today
        disbursement_frequency = ::Enum::DisbursementFrequencies::DAILY
        minimum_monthly_fee = Money.from_amount(100)

        merchant = described_class.new.call(
          id:, reference:, email:, live_on:,
          disbursement_frequency:,
          minimum_monthly_fee:
        )

        expect(merchant).to be_persisted
        expect(merchant.reference).to eq reference
        expect(merchant.email).to eq email
        expect(merchant.live_on).to eq live_on
        expect(merchant.disbursement_frequency).to eq disbursement_frequency
        expect(merchant.minimum_monthly_fee).to eq minimum_monthly_fee
        expect(merchant.id).to eq id
      end
    end
  end
end
