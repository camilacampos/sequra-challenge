desc "Calculate commissions for all disbursements"
task calculate_disbursements: :environment do
  puts "========== STARTED CALCULATING DISBURSEMENTS =========="
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  calculated = 0
  errors = []

  begin
    Disbursement.pending_or_processing.find_each do |disbursement|
      FinishDisbursementCalculation.new.call(disbursement)
      calculated += 1
      print "."
    end
  rescue => e
    print "F"
    errors << {disbursement_id: disbursement.id, errors: e}
  end

  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed = ending - starting

  puts "\n========== FINISHED CALCULATING DISBURSEMENTS =========="
  puts "\n-- SUMMARY --"
  puts "Elapsed time: #{elapsed.round(2)} seconds"
  puts "Total calculated disbursements: #{calculated}"

  if errors.any?
    puts "\n\n#{errors.count} errors:"
    puts errors.join("\n")
  else
    puts "\n\nNo errors"
  end
end
