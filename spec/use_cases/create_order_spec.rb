require "rails_helper"

RSpec.describe ::CreateOrder do
  it "raises an error when merchant is not found" do
    expect {
      described_class.new.call(
        reference: SecureRandom.hex(10),
        merchant_reference: SecureRandom.hex(10),
        amount: Money.from_amount(100)
      )
    }.to raise_error("Merchant not found")
  end

  it "raises an error when any attribute is invalid" do
    merchant = create(:merchant)

    expect {
      described_class.new.call(
        reference: nil,
        merchant_reference: merchant.reference,
        amount: nil
      )
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context "when all attributes are valid" do
    context "when created_at is not provided" do
      it "creates order using current date as created_at" do
        reference = "order-reference"
        amount = Money.from_amount(100)
        merchant = create(:merchant)

        order = described_class.new.call(
          reference:, amount:,
          merchant_reference: merchant.reference
        )

        expect(order).to be_persisted
        expect(order.reference).to eq reference
        expect(order.amount).to eq amount
        expect(order.merchant).to eq merchant
        expect(order.created_at).to be_within(1.minute).of(Time.zone.now)
      end
    end

    context "when created_at is provided" do
      it "creates order using the provided created_at" do
        reference = "order-reference"
        amount = Money.from_amount(100)
        merchant = create(:merchant)
        created_at = "2024-02-02"

        order = described_class.new.call(
          reference:, amount:, created_at:,
          merchant_reference: merchant.reference
        )

        expect(order).to be_persisted
        expect(order.reference).to eq reference
        expect(order.amount).to eq amount
        expect(order.merchant).to eq merchant
        expect(order.created_at).to eq Date.parse(created_at)
      end
    end

    it "calculates commission for the order" do
      reference = "order-reference"
      amount = Money.from_amount(100)
      merchant = create(:merchant)

      order = described_class.new.call(
        reference:, amount:,
        merchant_reference: merchant.reference
      )

      expect(order.commission).to be_present
    end
  end
end
