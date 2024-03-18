class RequestRefund
  def call(order_id:, amount:, date:, refund_class:)
    ActiveRecord::Base.transaction do
      refund = refund_class.create!(order_id:, amount:, date:)
      order = find_order(refund)
      disbursement = find_disbursement(order, refund)
      deduct_refund!(refund, disbursement)
    end
  end

  private

  def find_order(refund)
    Order.find(refund.order_id)
  end

  def find_disbursement(order, refund)
    merchant = order.merchant
    reference_date = reference_date_from(refund.date, merchant)

    Disbursement.pending_or_processing.find_by(merchant:, reference_date:)
  end

  def reference_date_from(refund_date, merchant)
    return refund_date if merchant.daily?

    live_on = merchant.live_on
    if wday(refund_date) == wday(live_on)
      refund_date
    else
      refund_date.prev_occurring(wday(live_on))
    end
  end

  def wday(date)
    date.strftime("%A").downcase.to_sym
  end

  def deduct_refund!(refund, disbursement)
    disbursement.disbursed_amount -= refund.amount
    disbursement.total_amount -= refund.amount
    disbursement.save!
  end
end
