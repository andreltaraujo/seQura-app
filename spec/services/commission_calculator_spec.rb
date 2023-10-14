require 'rails_helper'

RSpec.describe CommissionCalculator do
	let(:order) { create(:order) }
	let(:order_commission) { 
		{ order_amount: 453.28,
			sequra_amount: 3.85,
			merchant_amount: 449.43,
			fee_percentage: 0.0085,
			order_date: order.created_at,
			order_id: order.id,
			disbursement_id: nil,
			created_at: order.created_at,
		}
	}
	describe '#calculate' do
		context '#calculated_data' do
			it 'returns a hash with the calculated data' do
				commission_data = CommissionCalculator.new(order).calculate
				expect(commission_data).to eq(order_commission)
			end
		end
	end
end