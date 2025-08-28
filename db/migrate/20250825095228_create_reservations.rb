class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.date :reservation_date
      t.time :reservation_time
      t.integer :party_size
      t.string :status

      t.timestamps
    end
  end
end
