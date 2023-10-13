module Disbursements
	class DisbursementsTask

		def self.weekly_disbursements_dates(merchant)
			start_date = merchant.live_on
			end_date = Date.parse('08 Feb 2023')
			weeks = (start_date..end_date).to_a.group_by { |date| [date.cweek, date.year] }
			merchant_end_week_day = merchant.live_on.wday == 0 ? 6 : merchant.live_on.wday - 1
			weeks_dates = []
			weeks.each do |(week_number, year), dates|
				merchant_week_end_day = dates.select { |date| date.wday == merchant_end_week_day }
				merchant_end_week_date = merchant_week_end_day.first
				if merchant_end_week_date
					merchant_start_week_date = merchant_end_week_date - 6
					weeks_dates << { start_date: merchant_start_week_date, end_date: merchant_end_week_date }
				else
					"No valid date found"
					next
				end
			end
			weeks_dates
		end

		def self.execute	
			merchant = Merchant.where(disbursement_frequency: "WEEKLY").each do |merchant|
			weekly_disbursements_dates = weekly_disbursements_dates(merchant)
			weekly_disbursements_dates.each do |disbursement_dates|
					commissions_for_week = OrderCommission.joins(:order).where(orders: { merchant_reference: merchant.reference }).where(created_at: disbursement_dates[:start_date].beginning_of_day..disbursement_dates[:end_date].end_of_day)
						if commissions_for_week.any?
							order_fee_amount = commissions_for_week.sum(:sequra_amount_cents)
							amount = commissions_for_week.sum(:merchant_amount_cents)
							disbursement = nil
							begin
								Disbursement.transaction do
									disbursement = Disbursement.create!( 
									reference: SecureRandom.alphanumeric(13),	
									order_fee_amount: order_fee_amount,
										amount: amount,
										currency: 'EUR',
										created_at: disbursement_dates[:end_date] + 1.day
									)
									updated_associated_records = []
									commissions_for_week.each do |commission|
										commission.update(disbursement_id: disbursement.id)
										updated_associated_records << commission
										order = commission.order
										order.update(disbursement_id: disbursement.id, disbursement_reference: disbursement.reference)
										updated_associated_records << order
									end
								rescue ActiveRecord::RecordInvalid => e
									Rails.logger.error "[DisbursementsTask][Validation failed] #{e.message} #{e.backtrace}"
								rescue StandardError => e
									Rails.logger.error "[DisbursementsTask][error] #{e.message} #{e.backtrace}"
									Rails.logger.info "Disbursement created for #{updated_associated_records} for merchant #{merchant.reference}"
								end
							end
						else
							Rails.logger.info "No orders for week #{week_number} for merchant #{merchant.reference}"
						end
					end
				end
			end
		end

		def disbursement_day(merchant)
			start_date = merchant.live_on
			end_date = Date.parse('08 Feb 2023')
			weeks = (start_date..end_date).to_a.group_by { |date| [date.cweek, date.year] }
			merchant_end_week_day = merchant.live_on.wday == 0 ? 6 : merchant.live_on.wday - 1
			merchant_dates = []
			weeks.each do |(week_number, year), dates|
				merchant_week_day = dates.select { |date| date.wday == merchant.live_on.wday}
				disbursement_day = merchant_week_day.first
				if disbursement_day
					merchant_dates << disbursement_day
				else
				"No valid date found"
				end
			end
		end
	end
