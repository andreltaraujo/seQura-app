class OrderCommission < ApplicationRecord
  belongs_to :order
  belongs_to :disbursement
	
	validates :order_amount_cents, :sequra_amount_cents, :merchant_amount_cents, :fee_percentage, :order_date, :order_id, presence: true

	monetize :order_amount_cents
	monetize :sequra_amount_cents
	monetize :merchant_amount_cents
end
