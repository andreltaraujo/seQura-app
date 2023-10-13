class GetCommissionFee
	PERCENTAGE_FEE_100 = 0.01
	PERCENTAGE_FEE_095 = 0.0095
	PERCENTAGE_FEE_085 = 0.0085
	
	def commissioning_percentage_fee(order)
		case order.amount_cents
		when 0..Order::VALUE_FOR_FEE_100
			PERCENTAGE_FEE_100
		when Order::VALUES_FOR_FEE_095
			PERCENTAGE_FEE_095
		when Order::VALUE_FOR_FEE_085..Float::INFINITY
			PERCENTAGE_FEE_085
		end
	end
end
