class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :merchant_reference
      t.integer :amount_cents
      t.string :currency
      t.string :disbursement_reference
      t.belongs_to :disbursement, null: false, foreign_key: true
      t.belongs_to :merchant, null: false, foreign_key: true

      t.timestamps
    end
		add_index :orders, :merchant_reference
  end
end
