class CalculateFee
  def call(order)
    percentage = 0.85 / 100.0 # 0.85%
    if order.amount < Money.from_amount(50)
      percentage = 1 / 100.0 # 1%
    elsif order.amount < Money.from_amount(300)
      percentage = 0.95 / 100 # 0.95%
    end

    Fee.new(percentage:, from_amount: order.amount)
  end
end
