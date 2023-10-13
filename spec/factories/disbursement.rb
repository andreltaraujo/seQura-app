FactoryBot.define do
  factory :disbursement do
		order_fee_amount { 1.75 }
		amount { 176.26 }
		currency	{ 'EUR' }

		before(:create) do |disbursement|
			reference = Disbursement.new.send(:generate_reference)
			disbursement.reference = reference
		end
	end
end
