require "rails_helper"

RSpec.describe ::Enum::Base do
  enum = Class.new(described_class) do
    def self.all
      ["example1", "example2"]
    end
  end

  it "returns all enum values" do
    expect(enum.all).to eq ["example1", "example2"]
  end

  it "returns hashfied enum values, with enum being both key and value" do
    expect(enum.to_h).to eq({"example1" => "example1", "example2" => "example2"})
  end

  it "runs block for each enum value" do
    block_run = []

    enum.each do |value|
      block_run << "Block run for value: #{value}"
    end

    expect(block_run).to eq [
      "Block run for value: example1",
      "Block run for value: example2"
    ]
  end
end
