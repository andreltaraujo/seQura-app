require 'rails_helper'

RSpec.describe Disbursement, type: :model do
  describe 'validations' do
		subject { create(:disbursement) }
		it 'is valid with valid attributes' do
			expect(subject).to be_valid
		end

		it 'is not valid without reference' do
			subject.reference = nil 
			expect(subject).to_not be_valid
			expect(subject.errors[:reference]).to include("can't be blank")
		end
	end

	describe '#generate_reference' do
		it 'generates a reference with 13 characters' do
			disbursement = create(:disbursement)
			expect(disbursement.reference.length).to eq(13)
		end
		
		it 'verify if reference is unique' do
			disbursement = create(:disbursement)
			disbursement2 = create(:disbursement)
			expect(disbursement.reference).to_not eq(disbursement2.reference)
		end
	end
end
