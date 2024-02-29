class Merchants::Create
  def call(reference:, email:, live_on:, disbursement_frequency:, minimum_monthly_fee:, id: nil)
    Merchant.create!(
      id: id,
      reference: reference,
      email: email,
      live_on: live_on,
      disbursement_frequency: disbursement_frequency,
      minimum_monthly_fee: minimum_monthly_fee
    )
  end
end
