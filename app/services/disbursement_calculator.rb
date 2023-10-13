class DisbursementCalculator
	
	def initialize(order_commissions_for_disbursements)
		@order_commissions_for_disbursements = order_commissions_for_disbursements
	end

	def calculate
		DisbursementBuilder.new(calculated_data).build_disbursement
	end
	
	def order_fee_amount
		debugger
		@order_commissions_for_disbursements.sum(&:sequra_amount)
	end

	def merchant_amount
		@order_commissions_for_disbursements.sum(&:merchant_amount)
	end

	def calculated_data
		{
			order_fee_amount: order_fee_amount,
			amount: merchant_amount,
			currency: 'EUR'
		}
	end
end
