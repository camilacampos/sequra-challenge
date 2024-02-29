class CalculateFee
  def call(order)
    if order.amount < Money.from_amount(50)
      1 / 100.0 # 1%
    elsif order.amount < Money.from_amount(300)
      0.95 / 100.0 # 0.95%
    else
      0.85 / 100.0 # 0.85%
    end
  end
end
