class DisbursementGenerator

	def execute
		daily_merchants_to_process = merchants_daily
		weekly_merchants_to_process = merchants_weekly_today
		daily_merchants_to_process.each do |daily_merchant|
			day_date = Date.yesterday
			day_orders_to_process = fetch_day_orders(daily_merchant, day_date)
			if day_orders_to_process.any?
				generated_day_commissions = OrderCommissionGenerator.new.execute(day_orders_to_process)
				if generated_day_commissions.present?
					calculated_day_disbursement = DisbursementCalculator.new(generated_day_commissions).calculate
					begin
						Disbursement.transaction do
							created_day_disbursement = Disbursement.create(calculated_day_disbursement)
							updated_disbursed_day_commissions = []
							day_orders_to_process.each do |day_commission|
								day_commission.update(disbursement_id: created_disbursement.id)
								updated_disbursed_day_commissions << day_commission.id
								order = day_commission.order
								order.update(disbursement_id: created_day_disbursement.id, disbursement_reference: created_day_disbursement.reference)
								updated_disbursed_day_commissions << order.id
								Rails.logger.info "Day Disbursement created for #{updated_disbursed_day_commissions} for daily merchant #{daily_merchant.reference}"
							end
						end
					rescue ActiveRecord::RecordInvalid => invalid
						Rails.logger.error "[DisbursementsDailyTask][Validation failed] #{invalid.message} #{invalid.backtrace}"
						Rails.logger.info "Day Disbursement created for #{updated_disbursed_day_commissions} for daily merchant #{daily_merchant.reference}"
					rescue StandardError => e
						Rails.logger.error "[DisbursementsDailyTask][error] #{e.message} #{e.backtrace}"
					end
				else
					Rails.logger.info "[DisbursementsDailyTask][Order commissions wasn't generated] for daily merchant #{daily_merchant.reference}"
				end
			else
				Rails.logger.info "[DisbursementsDailyTask][No order commissions to process] for daily merchant #{daily_merchant.reference}"
			end
		end

		weekly_merchants_to_process.each do |weekly_merchant|
			week_dates = week_disbursements_dates(weekly_merchant)
			week_orders_to_process = fetch_week_orders(weekly_merchant, week_dates)
			if week_orders_to_process.any?
				debugger
				generated_week_commissions = OrderCommissionGenerator.new.execute(week_orders_to_process)
				if generated_week_commissions.present?
					calculated_week_disbursement = DisbursementCalculator.new(generated_week_commissions).calculate
					begin
						Disbursement.transaction do
							created_week_disbursement = Disbursement.create(calculated_week_disbursement)
							updated_disbursed_week_commissions = []
							week_orders_to_process.each do |commission|
								commission.update(disbursement_id: created_week_disbursement.id)
								updated_disbursed_week_commissions << commission.id
								order = commission.order
								order.update(disbursement_id: created_week_disbursement.id, disbursement_reference: created_week_disbursement.reference)
								updated_disbursed_week_commissions << order.id
								Rails.logger.info "Disbursement created for #{updated_disbursed_week_commissions} for weekly merchant #{weekly_merchant.reference}"
							end
						end
					rescue ActiveRecord::RecordInvalid => invalid
						Rails.logger.error "[DisbursementsWeeklyTask][Validation failed] #{invalid.message} #{invalid.backtrace}"
						Rails.logger.info "Week Disbursement created for #{updated_disbursed_week_commissions} for weekly merchant #{weekly_merchant.reference}"
					rescue StandardError => e
						Rails.logger.error "[DisbursementsWeeklyTask][error] #{e.message} #{e.backtrace}"
					end
				else
					Rails.logger.info "[DisbursementsWeeklyTask][Order commissions wasn't generated] for weekly merchant #{weekly_merchant.reference}"
				end
			else
				Rails.logger.info "[DisbursementsWeeklyTask][No order commissions to process] for weekly merchant #{weekly_merchant.reference}"
			end
		end
	end

	def week_disbursements_dates(weekly_merchant)
		current_date = Date.today
		current_week_day = Date.today.wday
		if weekly_merchant.live_on.wday == current_week_day # Make sure the eligible weekly merchant live_on day is the same as today, even it was checked and selected before
			week_dates = { 
				merchant_week_start_date: current_date - 6.days,
				merchant_week_end_date: current_date - 1.day
			}		
		else
			Rails.logger.info("[#{self.class.name}] nothing to process #{current_date}")
			return nil
		end
	end
	
	def merchants_daily
		Merchant.daily_eligible_merchants
	end

	def merchants_weekly_today
		Merchant.weekly_eligible_merchants		
	end
	def fetch_day_orders(daily_merchant, day_date)
		Order.daily_disbursements(merchant.reference, day_date)
	end

	def fetch_week_orders(weekly_merchant, week_dates)
		Order.weekly_disbursements(merchant.reference, week_dates[:merchant_week_start_date], dates[:merchant_week_end_date])
	end
end