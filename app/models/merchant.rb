class Merchant < ApplicationRecord
	has_many :orders
	has_many :disbursements, through: :orders

	validates :reference, :live_on, :disbursement_frequency, presence: true	
	validates :minimum_monthly_fee_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
	
	monetize :minimum_monthly_fee_cents

	scope :daily_eligible_merchants, -> { where(disbursement_frequency: 'DAILY') }
	scope :weekly_eligible_merchants, -> { where("EXTRACT(ISODOW FROM live_on) = ? AND disbursement_frequency = ?", Date.today.cwday, 'WEEKLY') }
end
