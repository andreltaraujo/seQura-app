class Disbursement < ApplicationRecord
	has_many :orders
	has_many :order_commissions

	validates :reference, :order_fee_amount_cents, :amount_cents, presence: true

	monetize :order_fee_amount_cents
	monetize :amount_cents

	before_validation :generate_reference, on: :create

	private

	def generate_reference
		self.reference = SecureRandom.alphanumeric(13)
	end
end
