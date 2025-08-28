class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :payment_status
      t.string :payment_method
      t.decimal :amount
      t.string :transaction_id
      t.datetime :paid_at

      t.timestamps
    end
  end
end
