desc "Generate disbursements report"
task generate_report: :environment do
  query = <<-SQL
    SELECT
      EXTRACT(YEAR FROM d.reference_date) AS year,
      COUNT(d.id) AS disbursements_count,
      SUM(d.total_amount_cents) AS amount_disbursed_in_cents,
      SUM(d.total_commission_fee_cents) AS commission_fees_in_cents,
      COUNT(d.monthly_fee_cents) FILTER (WHERE d.monthly_fee_cents IS NOT NULL) AS monthly_fees_count,
      SUM(d.monthly_fee_cents) AS monthly_fees_in_cents
    FROM disbursements d
    WHERE d.status = 'calculated'
    GROUP BY 1
    ORDER BY 1
  SQL

  data = []

  ActiveRecord::Base.connection_pool.with_connection do |connection|
    data = connection.execute(query).to_a
  end

  puts "\n-- REPORT --"
  data.each do |row|
    puts "----------------"
    puts "Year: #{row["year"].to_i}"
    puts "Number of disbursements: #{row["disbursements_count"]}"
    puts "Amount disbursed to merchants: #{Money.new(row["amount_disbursed_in_cents"])}"
    puts "Amount of order fees: #{Money.new(row["commission_fees_in_cents"])}"
    puts "Number of monthly fees charged: #{row["monthly_fees_count"]}"
    puts "Amount of monthly fee charged: #{Money.new(row["monthly_fees_in_cents"])}"
  end
end
