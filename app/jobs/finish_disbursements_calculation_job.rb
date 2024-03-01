class FinishDisbursementsCalculationJob < ApplicationJob
  def perform
    disbursements = Disbursement.pending_or_processing
      .where(reference_date: Date.today.beginning_of_day..Date.today.end_of_day)

    disbursements.each do |disbursement|
      FinishDisbursementCalculation.new.call(disbursement)
    end
  end
end
