class DisbursementGenerator

	def execute
		merchants_to_process = DisbursementGenerator.merchants_weekly_today
		merchants_to_process.each do |merchant|
			dates = DisbursementGenerator.weekly_disbursements_dates(merchant)
			orders_to_process = DisbursementGenerator.fetch_orders_weekly(merchant, dates)
			debugger
			if orders_to_process.any?
				generated_commissions = OrderCommissionGenerator.new.execute(orders_to_process)
				if generated_commissions.present?
					calculated_disbursement = DisbursementCalculator.new(generated_commissions).calculate
					begin
						Disbursement.transaction do
							created_disbursement = Disbursement.create(calculated_disbursement)
							updated_disbursed_week_commissions = []
							orders_to_process.each do |commission|
								commission.update(disbursement_id: created_disbursement.id)
								updated_disbursed_week_commissions << commission.id
								order = commission.order
								order.update(disbursement_id: created_disbursement.id, disbursement_reference: created_disbursement.reference)
								updated_disbursed_week_commissions << order.id
								Rails.logger.info "Disbursement created for #{updated_disbursed_week_commissions} for merchant #{merchant.reference}"
							end
						end
					rescue ActiveRecord::RecordInvalid => invalid
						Rails.logger.error "[DisbursementsWeeklyTask][Validation failed] #{invalid.message} #{invalid.backtrace}"
						Rails.logger.info "Disbursement created for #{updated_disbursed_commissions} for merchant #{merchant.reference}"
					rescue StandardError => e
						Rails.logger.error "[DisbursementsWeeklyTask][error] #{e.message} #{e.backtrace}"
					end
				else
					Rails.logger.info "[DisbursementsWeeklyTask][Order commissions wasn't generated] for merchant #{merchant.reference}"
				end
			else
				Rails.logger.info "[DisbursementsWeeklyTask][No order commissions to process] for merchant #{merchant.reference}"
			end
		end
	end

	def self.weekly_disbursements_dates(merchant)
		current_date = Date.today
		current_week_day = Date.today.wday
		if merchant.live_on.wday == current_week_day # Make sure the eligible merchant live_on day is the same as today
			dates = { 
				merchant_week_start_date: current_date - 6.days,
				merchant_week_end_date: current_date - 1.day
			}		
		else
			Rails.logger.info("[#{self.class.name}] nothing to process #{current_date}")
			return nil
		end
	end
	
	def self.merchants_daily
		Merchant.daily_eligible_merchants
	end

	def self.merchants_weekly_today
		Merchant.weekly_eligible_merchants		
	end
	def self.fetch_orders_daily(merchant, date)
		Order.daily_disbursements(merchant.reference, date)
	end

	def self.fetch_orders_weekly(merchant, dates)
		Order.weekly_disbursements(merchant.reference, dates[:merchant_week_start_date], dates[:merchant_week_end_date])
	end
end