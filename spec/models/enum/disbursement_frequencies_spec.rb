require "rails_helper"

RSpec.describe ::Enum::DisbursementFrequencies do
  it "returns all enum options" do
    expect(described_class.all).to eq [described_class::DAILY, described_class::WEEKLY]
  end
end
