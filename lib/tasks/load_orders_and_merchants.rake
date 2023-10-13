require 'csv'

namespace :dev do
	desc 'Setup data for development'
	task setup: :environment do
		if Rails.env.development?
			%x(rails db:drop db:create db:migrate)
			%x(rails import:load_merchants)
			%x(rails import:load_orders)
		else
			puts 'Not a development environment'
		end
	end
end
	
namespace :import do
  desc 'Import Merchants from CSV file'
  task :load_merchants => :environment do

    file_path = Rails.root.join('tmp', 'merchants.csv')

    CSV.foreach(file_path, headers: true, col_sep: ';') do |row|
			Merchant.create!(
				reference: row['reference'].to_s,
				email: row['email'].to_s,
				live_on: row['live_on'].to_datetime,
				disbursement_frequency: row['disbursement_frequency'].to_s,
				minimum_monthly_fee_cents: row['minimum_monthly_fee'].to_money.cents
			)
    end
    puts 'Merchants imported successfully.'
  end

	desc 'Import Orders from CSV file'
  task :load_orders => :environment do

    file_path = Rails.root.join('tmp', 'orders.csv')

    CSV.foreach(file_path, headers: true, col_sep: ';') do |row|
			Order.create!(
				merchant_reference: row['merchant_reference'].to_s,
				amount_cents: row['amount'].to_money.cents,
				currency: 'EUR',
				merchant: Merchant.find_by(reference: row['merchant_reference'].to_s),
				created_at: row['created_at'].to_datetime
			)
    end
    puts 'Orders imported successfully.'
  end

end
