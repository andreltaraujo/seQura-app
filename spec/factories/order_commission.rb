FactoryBot.define do
  factory :order_commission do
    order_amount { 25.43 }
    sequra_amount { 0.25 }
    merchant_amount { 25.18 }
    fee_percentage { 0.01 }
    order_date { Date.yesterday}
    disbursement { nil }
  end

	trait :with_disbursement do
		association	:disbursement
	end

	trait :with_orders do
		transient do
			orders_count { 7 } # Default number of orders to create
		end
		association	:order
	end
end