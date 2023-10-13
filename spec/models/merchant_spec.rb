require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'validations' do
		subject { build(:merchant) }
		
		it 'is valid with valid attributes' do
			expect(subject).to be_valid
		end
		
		it 'is not valid without a reference' do
      subject.reference = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:reference]).to include("can't be blank")
    end

		it 'is not valid without a live_on' do
      subject.live_on = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:live_on]).to include("can't be blank")
    end

    it 'is not valid without an minimum_monthly_fee_cents' do
      subject.minimum_monthly_fee_cents = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:minimum_monthly_fee_cents]).to include("can't be blank")
    end
	end
end