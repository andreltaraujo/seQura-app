class CommissionCalculator
	
	def initialize(order)
		@order = order
	end

	def calculate
		Commission.new(calculated_data).build_commission
	end

	def pricing_commission
		get_commission_pricing
	end
	
	def order_amount
		@order.amount_cents.to_f.round(2) / 100
	end

	def sequra_amount
		(order_amount * pricing_commission).to_f.round(2)
	end

	def merchant_amount
		(order_amount - sequra_amount).round(2)
	end

	def fee_percentage
		pricing_commission
	end

	def order_date
		@order.created_at
	end

	def order_id
		@order.id
	end

	def calculated_data
		{
			order_amount: order_amount,
			sequra_amount: sequra_amount,
			merchant_amount: merchant_amount,
			fee_percentage: fee_percentage,
			order_date: order_date,
			order_id: order_id,
			created_at: order_date
		}
	end

	private
	
	def get_commission_pricing
		GetCommissionFee.new.commissioning_percentage_fee(@order)
	end
end