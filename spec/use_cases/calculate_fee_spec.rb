require "rails_helper"

RSpec.describe ::CalculateFee do
  it "returns 1% when amount is less than 50" do
    order = build(:order, amount: Money.from_amount(49))

    expect(described_class.new.call(order)).to eq 1 / 100.0
  end

  it "returns 0.95% when amount is between 50 and 300" do
    order1 = build(:order, amount: Money.from_amount(50))
    order2 = build(:order, amount: Money.from_amount(299))

    expect(described_class.new.call(order1)).to eq 0.95 / 100.0
    expect(described_class.new.call(order2)).to eq 0.95 / 100.0
  end

  it "returns 0.85% when amount is greater than or equal to 300" do
    order1 = build(:order, amount: Money.from_amount(300))
    order2 = build(:order, amount: Money.from_amount(500))

    expect(described_class.new.call(order1)).to eq 0.85 / 100.0
    expect(described_class.new.call(order2)).to eq 0.85 / 100.0
  end
end
