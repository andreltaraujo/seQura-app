require 'rails_helper'

RSpec.describe OrderCommission, type: :model do
  let(:order) { create(:order) }
	let(:commission_order)	{
		{
 			order_amount: 25.43,
			sequra_amount: 0.25,
			merchant_amount: 25.18,
			fee_percentage: 0.01,
			order_date: order.created_at,
			order: order,
			disbursement_id: nil,
			created_at: order.created_at
		}
	}
	subject { build(:order_commission, order: order) }
  
	describe 'validations' do	
		it 'is valid with valid attributes' do
			expect(subject).to be_valid
		end
		
		it 'is not valid without a order_amount' do
      subject.order_amount_cents = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:order_amount_cents]).to include("can't be blank")
    end

		it 'is not valid without sequra_amount' do
      subject.sequra_amount_cents = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:sequra_amount_cents]).to include("can't be blank")
    end

    it 'is not valid without merchant_amount' do
      subject.merchant_amount_cents = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:merchant_amount_cents]).to include("can't be blank")
    end

		it 'is not valid without fee_percantage' do
      subject.fee_percentage = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:fee_percentage]).to include("can't be blank")
    end

		it 'is not valid without order_date' do
      subject.order_date = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:order_date]).to include("can't be blank")
    end

		it 'is not valid without order_id' do
      subject.order_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:order_id]).to include("can't be blank")
    end


	end
end