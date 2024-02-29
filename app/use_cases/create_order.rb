class CreateOrder
  def call(reference:, merchant_reference:, amount:, created_at: Time.zone.now)
    merchant = find_merchant(merchant_reference)
    order = create_order(reference:, merchant:, amount:, created_at:)
    calculate_commission(order)

    order
  end

  private

  def find_merchant(reference)
    Merchant.find_by(reference: reference).tap do |merchant|
      raise "Merchant not found" unless merchant
    end
  end

  def create_order(reference:, merchant:, amount:, created_at:)
    Order.create!(reference:, merchant:, amount:, created_at:)
  end

  def calculate_commission(order)
  end
end
