require 'rails_helper'

RSpec.describe OrderCommissionGenerator do
	describe '#execute' do
	let(:merchant) { create(:merchant) }
	let(:orders) { create_list(:order, 7, :weekly_orders, merchant: merchant) }
		
	context 'When there is no order commission generated yet' do
		it 'creates a new order commission' do
			expect do
				OrderCommissionGenerator.new.execute(orders)
			end.to change(OrderCommission, :count).by(7)
		end
	end
	
	context 'When there is already an order commission generated' do
		it 'does not create a new order commission' do
			orders.map { |order| create(:order_commission, order: order) }
			expect do
					OrderCommissionGenerator.new.execute(orders)
				end.to_not change(OrderCommission, :count)
			end
		end
	end
end