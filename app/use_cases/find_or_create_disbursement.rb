class FindOrCreateDisbursement
  def call(order)
    find_disbursement(order) || create_disbursement(order)
  end

  private

  def find_disbursement(order)
    if order.merchant.daily?
      Disbursement.find_by(merchant: order.merchant, reference_date: order.created_at.to_date)
    else
      reference_date = reference_date_from(order)

      Disbursement.find_by(merchant: order.merchant, reference_date:)
    end
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

    weekday = order.merchant.live_on.wday
    if created_at.wday == weekday
      created_at
    else
      created_at.prev_occurring(number_to_weekday(weekday))
    end
  end

  def number_to_weekday(number)
    {
      1 => :monday,
      2 => :tuesday,
      3 => :wednesday,
      4 => :thursday,
      5 => :friday,
      6 => :saturday,
      7 => :sunday
    }.fetch(number)
  end
end
