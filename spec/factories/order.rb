FactoryBot.define do
  factory :order do
		merchant_reference  { "wintheiser_bernhard" }
		amount { 453.28 }
		currency { "EUR" }
		disbursement_reference { nil }
		disbursement_id { nil }
		association :merchant, factory: :merchant
		created_at { Date.yesterday }

		trait :weekly_orders do
			transient do
				orders_count { 7 }
			end
			
			after(:create) do |merchant, evaluator|
				evaluator.orders_count.times do |n|
					create(:order, created_at: Date.yesterday - n.days)
				end
			end 
		end
  end
end
