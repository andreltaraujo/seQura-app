class OrderCommission < ApplicationRecord
  belongs_to :order
  belongs_to :disbursement
end
