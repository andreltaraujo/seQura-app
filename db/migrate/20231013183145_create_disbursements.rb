class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements do |t|
      t.string :reference
      t.integer :order_fee_amount_cents
      t.integer :amount_cents
      t.string :currency

      t.timestamps
    end
  end
end
