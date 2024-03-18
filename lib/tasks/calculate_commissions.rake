desc "Calculates commissions from all orders"
task calculate_commissions: :environment do
  puts "========== STARTED CALCULATING COMMISSIONS =========="
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  calculated_commissions = 0
  errors = []

  query = Order.left_joins(:commission).where(commission: {id: nil})

  query.find_in_batches(batch_size: 5) do |batch|  # max connection pools
    mutex = Mutex.new
    batch.map do |order|
      Thread.new do
        CalculateCommission.new.call(order: order)
        mutex.synchronize do
          calculated_commissions += 1
          print "." if calculated_commissions % 1000 == 0
        end
      rescue => e
        mutex.synchronize do
          print "F"
          errors << {order_id: order.id, error: e}
        end
      end
    end.each(&:join)
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
