require 'rails_helper'

RSpec.describe Commission do

	let(:calculated_data) {
		{ order_amount: 453.28,
			sequra_amount: 3.85,
			merchant_amount: 449.43,
			fee_percentage: 0.0085,
			order_date: DateTime.new(2023, 1, 21),
			order_id: 123456,
			disbursement_id: nil,
			created_at: DateTime.new(2023, 1, 21),
		}
	}
	subject { described_class.new(calculated_data) }
	describe '#build commission' do
		it 'returns an commission hash' do
			commission = subject.build_commission
			expect(commission).to eq(calculated_data)
		end
	end
end
