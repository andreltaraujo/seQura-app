class CreateOrderCommissions < ActiveRecord::Migration[7.0]
  def change
    create_table :order_commissions do |t|
      t.integer :order_amount_cents
      t.integer :sequra_amount_cents
      t.integer :merchant_amount_cents
      t.decimal :fee_percentage
      t.date :order_date
      t.belongs_to :order, null: false, foreign_key: true
      t.belongs_to :disbursement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
