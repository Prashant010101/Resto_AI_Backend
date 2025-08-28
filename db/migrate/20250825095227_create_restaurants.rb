class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :phone_number
      t.string :email
      t.text :description
      t.integer :total_tables

      t.timestamps
    end
  end
end
