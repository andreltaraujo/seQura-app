class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants do |t|
      t.string :reference
      t.string :email
      t.date :live_on
      t.string :disbursement_frequency
      t.integer :minimum_monthly_fee_cents

      t.timestamps
    end
  end
end
