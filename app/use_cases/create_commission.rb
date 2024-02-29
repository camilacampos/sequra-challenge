class CreateCommission
  def call(order:, disbursement:, fee:)
    ::Commission.create!(
      order:, disbursement:,
      order_amount: fee.order_amount,
      fee_percentage: fee.percentage,
      fee_value: fee.value,
      disbursed_amount: fee.disbursed_amount
    )
  end
end
