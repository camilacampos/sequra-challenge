class Fee
  attr_reader :percentage, :order_amount

  def initialize(percentage:, from_amount:)
    @percentage = percentage
    @order_amount = from_amount
  end

  def value
    percentage * order_amount
  end

  def disbursed_amount
    order_amount - value
  end

  def ==(other)
    percentage == other.percentage &&
      value == other.value &&
      order_amount == other.order_amount
  end
end
