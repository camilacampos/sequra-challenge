require "csv"

desc "Creates merchants from a CSV file"
task create_merchants: :environment do
  file_path = "merchants.csv"

  if File.exist?(file_path)
    opts = {headers: true, col_sep: ";", converters: [:numeric, :date]}
    data = CSV.read(file_path, **opts)
  else
    puts "FILE NOT FOUND: #{file_path}"
    exit 1
  end

  puts "========== STARTED CREATING MERCHANTS =========="

  created = 0
  existing = 0
  errors = []

  data.each do |row|
    Money.from_amount(row["minimum_monthly_fee"])
    existing_merchant = Merchant.find_by(reference: row["reference"])
    if existing_merchant
      print "."
      existing += 1
      next
    end

    Merchants::Create.new.call(
      id: row["id"],
      reference: row["reference"],
      email: row["email"],
      live_on: row["live_on"],
      disbursement_frequency: row["disbursement_frequency"].downcase,
      minimum_monthly_fee: Money.from_amount(row["minimum_monthly_fee"])
    )
    print "."
    created += 1
  rescue ActiveRecord::RecordInvalid => e
    print "F"
    existing += 1
    errors << {merchant: row.to_h, errors: e.full_messages}
  end

  puts "\n========== FINISHED CREATING MERCHANTS =========="
  puts "\n-- SUMMARY --"
  puts "Total merchants in CSV: #{data.count}"
  puts "Total merchants created: #{created}"
  puts "Total already existing merchants: #{existing}"

  puts "\n\n#{errors.count} errors:"
  puts errors.join("\n")
end
