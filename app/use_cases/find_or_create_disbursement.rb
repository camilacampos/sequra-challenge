class FindOrCreateDisbursement
  def call(order)
    find_disbursement(order) || create_disbursement(order)
  end

  private

  def find_disbursement(order)
    reference_date = reference_date_from(order)

    Disbursement.pending_or_processing.find_by(merchant: order.merchant, reference_date:)
  end

  def create_disbursement(order)
    Disbursement.create!(
      reference: SecureRandom.hex(10),
      reference_date: reference_date_from(order),
      frequency: order.merchant.disbursement_frequency,
      merchant: order.merchant
    )
  end

  def reference_date_from(order)
    created_at = order.created_at.to_date

    return created_at if order.merchant.daily?

    live_on = order.merchant.live_on
    if wday(created_at) == wday(live_on)
      created_at
    else
      created_at.prev_occurring(wday(live_on))
    end
  end

  def wday(date)
    date.strftime("%A").downcase.to_sym
  end
end
