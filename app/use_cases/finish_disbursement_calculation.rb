class FinishDisbursementCalculation
  def call(disbursement)
    disbursement.monthly_fee = calculate_monthly_fee(disbursement)
    disbursement.status = Enum::DisbursementStatuses::CALCULATED
    disbursement.calculated_at = Time.zone.now

    disbursement.save!
  end

  private

  def calculate_monthly_fee(disbursement)
    return 0 unless disbursement.first_of_the_month?

    merchant = disbursement.merchant

    last_month_disbursements = Disbursement
      .by_month(disbursement.reference_date.prev_month)
      .by_merchant(merchant)
      .calculated

    last_month_commissions = Money.new(last_month_disbursements.sum(:total_commission_fee_cents))

    return 0 if merchant.minimum_monthly_fee < last_month_commissions

    disbursement.monthly_fee = merchant.minimum_monthly_fee - last_month_commissions
  end
end
