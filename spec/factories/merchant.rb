FactoryBot.define do
  factory :merchant do
 		reference { "wintheiser_bernhard" }
 		email { "info@wintheiser-bernhard.com" }
 		live_on { '07-10-2022' }
 		disbursement_frequency { "DAILY" }
 		minimum_monthly_fee { 15.00 }
  end

	trait :weekly do
		disbursement_frequency { "WEEKLY" }
		live_on { Date.today }
	end
end
