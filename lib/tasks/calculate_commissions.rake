desc "Calculates commissions from all orders"
task calculate_commissions: :environment do
  puts "========== STARTED CALCULATING COMMISSIONS =========="
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  calculated_commissions = 0
  errors = []

  Order.left_joins(:commission).where(commission: {id: nil}).find_each do |order|
    CalculateCommission.new.call(order: order)
    calculated_commissions += 1
    print "." if calculated_commissions % 1000 == 0
  rescue => e
    print "F"
    errors << {order_id: order.id, error: e}
  end

  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed = ending - starting

  puts "\n========== FINISHED CREATING ORDERS =========="
  puts "\n-- SUMMARY --"
  puts "Elapsed time: #{elapsed.round(2)} seconds"
  puts "Total commissions calculated: #{calculated_commissions}"

  if errors.any?
    puts "\n\n#{errors.count} errors:"
    puts errors.join("\n")
  else
    puts "\n\nNo errors"
  end
end
