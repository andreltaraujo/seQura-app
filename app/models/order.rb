class Order < ApplicationRecord
  belongs_to :disbursement
  belongs_to :merchant
	VALUE_FOR_FEE_100 = 4999
	VALUES_FOR_FEE_095 = (5000..29999)
	VALUE_FOR_FEE_085 = 30000
	
	belongs_to :disbursement, optional: true
	belongs_to :merchant
	has_one :order_commission, dependent: :destroy
	
	validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
	validates :merchant_reference, presence: true	
	
	monetize :amount_cents
	
	scope :for_merchant, ->(merchant_reference) { where(merchant_reference: merchant_reference) }
	scope :daily_disbursements, ->(merchant_reference, date) { for_merchant(merchant_reference).where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :within_date_range, ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
	scope :not_disbursed, -> { where(disbursement_id: nil, disbursement_reference: nil) }
  scope :weekly_disbursements, ->(merchant_reference, start_date, end_date) {
		for_merchant(merchant_reference)
		.within_date_range(start_date, end_date)
		.not_disbursed
	}
end
