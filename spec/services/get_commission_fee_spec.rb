require 'rails_helper'

RSpec.describe GetCommissionFee do
	describe '#commissioning_percentage_fee' do
		context 'when order amount is less then 50.00' do
			it 'sets commission to 1%' do
				order = create(:order, amount: 10.00)
				fee = described_class.new.commissioning_percentage_fee(order)
				expect(fee).to eq(0.01)
			end
		end

		context 'when order amount is between 50.00 and 299.00' do
			it 'sets commission to 0.95%' do
				order = create(:order, amount: 50.00)
				fee = described_class.new.commissioning_percentage_fee(order)
				expect(fee).to eq(0.0095)
			end
		end

		context 'when order amount is greater than 300.00' do
			it 'sets commission to 0.85%' do
				order = create(:order, amount: 1000.00)
				fee = described_class.new.commissioning_percentage_fee(order)
				expect(fee).to eq(0.0085)
			end
		end
	end
end