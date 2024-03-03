require "csv"

desc "Creates orders from a CSV file"
task create_orders: :environment do
  puts "========== STARTED CREATING ORDERS =========="
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  created = 0
  existing = 0
  errors = []

  file_path = "orders.csv"
  opts = {headers: true, col_sep: ";", converters: [:numeric, :date]}
  CSV.foreach(file_path, **opts) do |row|
    existing_order = Order.find_by(reference: row["id"])
    if existing_order
      print "."
      existing += 1
      next
    end

    CreateOrder.new.call(
      reference: row["id"],
      merchant_reference: row["merchant_reference"],
      amount: Money.from_amount(row["amount"]),
      created_at: row["created_at"]
    )
    print "."
    created += 1
  rescue ActiveRecord::RecordInvalid => e
    print "E"
    errors << {order: row.to_h, errors: e.full_messages}
  rescue => e
    print "F"
    errors << {order: row.to_h, errors: e}
  end

  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed = ending - starting

  puts "\n========== FINISHED CREATING ORDERS =========="
  puts "\n-- SUMMARY --"
  puts "Elapsed time: #{elapsed.round(2)} seconds"
  puts "Total orders created: #{created}"
  puts "Total already existing orders: #{existing}"

  if errors.any?
    puts "\n\n#{errors.count} errors:"
    puts errors.join("\n")
  else
    puts "\n\nNo errors"
  end
end
