require 'rails_helper'

RSpec.describe DisbursementCalculator do
	describe '#calculate' do
		commissions = []
		10.times do |order_commission|
			commission = OrderCommission.new(order_amount: 25.43, sequra_amount: 0.25, merchant_amount: 25.18)
			commissions << commission
		end
		calculated_data = {
			order_fee_amount: commissions.sum(&:sequra_amount),
			amount: commissions.sum(&:merchant_amount), currency: 'EUR'
		 }

		context '#calculated_data' do
		it 'returns a hash with the calculated data' do
				disbursement_data = DisbursementCalculator.new(commissions).calculate
				expect(disbursement_data).to eq(calculated_data)
			end
		end
	end
end