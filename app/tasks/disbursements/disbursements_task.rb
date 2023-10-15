module Disbursements
	class DisbursementsTask

		def execute
			daily_merchants = Merchant.where(disbursement_frequency: "DAILY").each do |daily_merchant|
				daily_disbursement_day = disbursement_day(daily_merchant)
				daily_disbursement_day.each do |daily_disbursement_date|
					commissions_for_day = OrderCommission.joins(:order).where(orders: { merchant_reference: daily_merchant.reference }).where(created_at: daily_disbursement_date.beginning_of_day..daily_disbursement_date.end_of_day)
					if commissions_for_day.any?
						commission_day_data = commissions_for_day.map do |commission|
							{
								id: commission.id,
								order_amount_cents: commission.order_amount_cents,
								sequra_amount_cents: commission.sequra_amount_cents,
								merchant_amount_cents: commission.merchant_amount_cents,
								fee_percentage: commission.fee_percentage,
								order_date: commission.order_date,
								order_id: commission.order_id,
								disbursement_id: commission.disbursement_id,
								created_at: commission.created_at
							}
						end
						Rails.logger.info "[DisbursementsDailyTask][Comissions of the Day] #{commission_day_data}"

						orders_for_day = Order.where(merchant_reference: daily_merchant.reference).where(created_at: daily_disbursement_date.beginning_of_day..daily_disbursement_date.end_of_day)
						orders_day_data = orders_for_day.map do |order|
							{
								id: order.id,
								merchant_reference: order.merchant_reference,
								amount_cents: order.amount_cents
							}
						end
						Rails.logger.info "[DisbursementsDailyTask][Orders of the Day] #{orders_day_data}"

						begin
						calculated_day_disbursement = DisbursementCalculator.new(commissions_for_day).calculate

						calculated_day_disbursement_data = {
							order_fee_amount: calculated_day_disbursement[:order_fee_amount],
							amount: calculated_day_disbursement[:amount]
						}
						Rails.logger.info "[DisbursementsDailyTask][Disbursement calculated] #{calculated_day_disbursement_data}"
							created_day_disbursement = nil
							Disbursement.transaction do
								disbursement_reference = SecureRandom.alphanumeric(13)
								created_at_date = daily_disbursement_date
								created_day_disbursement = Disbursement.create(calculated_day_disbursement.merge(reference: disbursement_reference, created_at:created_at_date))
								created_day_disbursement_data = {
									reference: created_day_disbursement.reference,
									order_fee_amount_cents: created_day_disbursement.order_fee_amount_cents,
									amount_cents: created_day_disbursement.amount_cents,
									currency: created_day_disbursement.currency,
									created_at: created_day_disbursement.created_at
								}
								Rails.logger.info "[DisbursementsDailyTask][Disbursement created] #{created_day_disbursement}"

								data_report = {
									merchant_reference: daily_merchant.reference,
									day_date: created_at_date,
									day_orders: orders_day_data.map { |order| [order[:id], order[:merchant_reference], order[:amount_cents]] },
									commission_day_data: commission_day_data.map { |commission| [commission[:id], commission[:order_amount_cents], commission[:sequra_amount_cents], commission[:merchant_amount_cents], commission[:fee_percentage], commission[:order_date], commission[:order_id], commission[:disbursement_id], commission[:created_at]] },
									calculated_day_disbursement: calculated_day_disbursement_data,
									created_day_disbursement: created_day_disbursement.attributes
								}
								report_directory = "tmp/reports"
								FileUtils.mkdir_p(report_directory) unless File.directory?(report_directory)
								file_path = File.join(report_directory, "daily_merchant_report_#{daily_merchant.reference}.json")
								report_json = data_report.to_json
								File.open(file_path, "w") do |file|
									file.puts(report_json)
								end

								updated_associated = []
								commissions_for_day.each do |commission|
									commission.update(disbursement_id: created_day_disbursement.id)
									updated_associated << commission
									order = commission.order
									order.update(disbursement_id: created_day_disbursement.id, disbursement_reference: created_day_disbursement.reference)
									updated_associated << order
								end
							end
						rescue ActiveRecord::RecordInvalid => e
							Rails.logger.error "[DisbursementsTask][Validation failed] #{e.message} #{e.backtrace}"
						rescue StandardError => e
							Rails.logger.error "[DisbursementsTask][error] #{e.message} #{e.backtrace}"
							Rails.logger.info "Disbursement created for #{updated_associated_records} for merchant #{daily_merchant.reference}"
						end
					else
						Rails.logger.info "No orders today #{daily_disbursement_date} for merchant #{daily_merchant.reference}"
					end
				end
			end

			weekly_merchant = Merchant.where(disbursement_frequency: "WEEKLY").each do |weekly_merchant|
			weekly_disbursements_dates = week_disbursements_dates(weekly_merchant)
			weekly_disbursements_dates.each do |weekly_disbursement_dates|
				commissions_for_week = OrderCommission.joins(:order).where(orders: { merchant_reference: weekly_merchant.reference }).where(created_at: weekly_disbursement_dates[:start_date].beginning_of_day..weekly_disbursement_dates[:end_date].end_of_day)
					if commissions_for_week.any?
						calculated_week_disbursement = DisbursementCalculator.new(commissions_for_week).calculate
						begin
							Disbursement.transaction do
								created_at_date = weekly_disbursement_dates[:end_date] + 1.day
								created_week_disbursement = Disbursement.create(calculated_week_disbursement.merge(created_at:created_at_date))
								report_data = {
									merchant_reference: weekly_merchant.reference,
									week_dates: weekly_disbursements_dates,
									week_orders_to_process: commissions_for_week.map { |commission| commission.order.attributes },
									week_commissions: commissions_for_week.map { |commission| commission.attributes },
									calculated_week_disbursement: [calculated_week_disbursement[:order_fee_amount], calculated_week_disbursement[:currency], calculated_week_disbursement[:amount]],
									created_week_disbursement: created_week_disbursement.attributes
								}
								report_directory = "tmp/reports"
								FileUtils.mkdir_p(report_directory) unless File.directory?(report_directory)

								file_path = File.join(report_directory, "weekly_merchant_report_#{weekly_merchant.reference}.json")

								report_json = report_data.to_json

								File.open(file_path, "w") do |file|
									file.puts(report_json)
								end

								updated_associated_records = []
								commissions_for_week.each do |commission|
									commission.update(disbursement_id: created_week_disbursement.id)
									updated_associated_records << commission
									order = commission.order
									order.update(disbursement_id: created_week_disbursement.id, disbursement_reference: created_week_disbursement.reference)
									updated_associated_records << order
								end
							rescue ActiveRecord::RecordInvalid => e
								Rails.logger.error "[DisbursementsTask][Validation failed] #{e.message} #{e.backtrace}"
							rescue StandardError => e
								Rails.logger.error "[DisbursementsTask][error] #{e.message} #{e.backtrace}"
								Rails.logger.info "Disbursement created for #{updated_associated_records} for merchant #{weekly_merchant.reference}"
							end
						end
					else
						Rails.logger.info "No orders for week #{week_number} for merchant #{weekly_merchant.reference}"
					end
				end
			end
		end

		def disbursement_day(merchant)
			start_date = merchant.live_on
			end_date = Date.parse('08 Feb 2023')
			disbursement_days = (start_date..end_date)
		end

		def week_disbursements_dates(weekly_merchant)
			start_date = weekly_merchant.live_on
			end_date = Date.parse('08 Feb 2023')
			weeks = (start_date..end_date).to_a.group_by { |date| [date.cweek, date.year] }
			weekly_merchant_end_week_day = weekly_merchant.live_on.wday == 0 ? 6 : weekly_merchant.live_on.wday - 1
			weeks_dates = []
			weeks.each do |(week_number, year), dates|
				weekly_merchant_week_end_day = dates.select { |date| date.wday == weekly_merchant_end_week_day }
				weekly_merchant_end_week_date = weekly_merchant_week_end_day.first
				if weekly_merchant_end_week_date
					merchant_start_week_date = weekly_merchant_end_week_date - 6
					weeks_dates << { start_date: merchant_start_week_date, end_date: weekly_merchant_end_week_date }
				else
					"No valid date found"
					next
				end
			end
			weeks_dates
		end
	end
end
