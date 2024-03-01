require "rails_helper"

RSpec.describe ::Fee do
  it "initializes with percentage and amount" do
    fee = described_class.new(percentage: 30 / 100.0, from_amount: Money.from_amount(100))

    expect(fee.percentage).to eq 0.3
    expect(fee.order_amount).to eq Money.from_amount(100)
  end

  it "returns the value of the fee" do
    fee = described_class.new(percentage: 30 / 100.0, from_amount: Money.from_amount(100))

    expect(fee.value).to eq Money.from_amount(30)
  end

  it "returns the disbursed amount" do
    fee = described_class.new(percentage: 30 / 100.0, from_amount: Money.from_amount(100))

    expect(fee.disbursed_amount).to eq Money.from_amount(70)
  end

  it "it equal to other fee by their attributes" do
    fee1 = described_class.new(percentage: 0.85 / 100.0, from_amount: Money.from_amount(100))
    fee2 = described_class.new(percentage: 0.85 / 100.0, from_amount: Money.from_amount(100))

    expect(fee1).to eq fee2
  end
end
