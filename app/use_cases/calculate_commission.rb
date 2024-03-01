class CalculateCommission
  def call(order:)
    ActiveRecord::Base.transaction do
      disbursement = find_or_create_disbursement!(order)
      fee = calculate_fee(order)
      commission = create_commission!(order, disbursement, fee)
      disbursement.update_totals_from!(commission)
    end
  end

  private

  def find_or_create_disbursement!(order)
    ::FindOrCreateDisbursement.new.call(order)
  end

  def calculate_fee(order)
    ::CalculateFee.new.call(order)
  end

  def create_commission!(order, disbursement, fee)
    ::CreateCommission.new.call(order:, disbursement:, fee:)
  end
end
