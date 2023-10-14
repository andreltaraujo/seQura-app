require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    subject { create(:order) }
		
		it 'is valid with valid attributes' do
			expect(subject).to be_valid
		end

		it 'is not valid without merchant reference' do
			subject.merchant_reference = nil 
			expect(subject).to_not be_valid
			expect(subject.errors[:merchant_reference]).to include("can't be blank")
		end
  end
end

