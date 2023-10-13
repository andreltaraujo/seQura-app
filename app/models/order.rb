class Order < ApplicationRecord
  belongs_to :disbursement
  belongs_to :merchant
end
