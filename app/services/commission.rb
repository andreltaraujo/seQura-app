class Commission
  
  def initialize(calculated_data)
    @calculated_data = calculated_data
  end

  def build_commission
    {
      order_amount: @calculated_data[:order_amount],
      sequra_amount: @calculated_data[:sequra_amount], 
      merchant_amount: @calculated_data[:merchant_amount],
      fee_percentage: @calculated_data[:fee_percentage],
      order_date: @calculated_data[:order_date],
      order_id: @calculated_data[:order_id],
      disbursement_id: @calculated_data[:disbursement_id],
			created_at: @calculated_data[:created_at]
    }
  end
end
