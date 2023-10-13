
class DisbursementBuilder
  
  def initialize(calculated_data)
    @calculated_data = calculated_data
  end

  def build_disbursement
    {
      order_fee_amount: @calculated_data[:order_fee_amount],
      amount: @calculated_data[:amount], 
      currency: 'EUR'
		}
	end
end
