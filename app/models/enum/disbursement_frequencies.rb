class Enum::DisbursementFrequencies < Enum::Base
  DAILY = "daily"
  WEEKLY = "weekly"

  def self.all
    [DAILY, WEEKLY]
  end
end
