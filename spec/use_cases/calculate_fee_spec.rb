require "rails_helper"

RSpec.describe ::CalculateFee do
  it "returns 1% when amount is less than 50" do
    order = build(:order, amount: Money.from_amount(49))

    fee = described_class.new.call(order)

    expect(fee.percentage).to eq 1 / 100.0
    expect(fee.order_amount).to eq order.amount
    expect(fee.value).to eq(order.amount * 1 / 100.0)
    expect(fee.disbursed_amount).to eq(order.amount - fee.value)
  end

  it "returns 0.95% when amount is equal to 50" do
    order = build(:order, amount: Money.from_amount(50))

    fee = described_class.new.call(order)

    expect(fee.percentage).to eq 0.95 / 100.0
    expect(fee.order_amount).to eq order.amount
    expect(fee.value).to eq(order.amount * 0.95 / 100.0)
    expect(fee.disbursed_amount).to eq(order.amount - fee.value)
  end

  it "returns 0.95% when amount is between 50 and 300" do
    order = build(:order, amount: Money.from_amount(299))

    fee = described_class.new.call(order)

    expect(fee.percentage).to eq 0.95 / 100.0
    expect(fee.order_amount).to eq order.amount
    expect(fee.value).to eq(order.amount * 0.95 / 100.0)
    expect(fee.disbursed_amount).to eq(order.amount - fee.value)
  end

  it "returns 0.85% when amount is equal to 300" do
    order = build(:order, amount: Money.from_amount(300))

    fee = described_class.new.call(order)

    expect(fee.percentage).to eq 0.85 / 100.0
    expect(fee.order_amount).to eq order.amount
    expect(fee.value).to eq(order.amount * 0.85 / 100.0)
    expect(fee.disbursed_amount).to eq(order.amount - fee.value)
  end

  it "returns 0.85% when amount is greater than 300" do
    order = build(:order, amount: Money.from_amount(301))

    fee = described_class.new.call(order)

    expect(fee.percentage).to eq 0.85 / 100.0
    expect(fee.order_amount).to eq order.amount
    expect(fee.value).to eq(order.amount * 0.85 / 100.0)
    expect(fee.disbursed_amount).to eq(order.amount - fee.value)
  end
end
