class Enum::DisbursementStatuses < Enum::Base
  PENDING = "pending"
  PROCESSING = "processing"
  CALCULATED = "calculated"

  def self.all
    [PENDING, PROCESSING, CALCULATED]
  end
end
