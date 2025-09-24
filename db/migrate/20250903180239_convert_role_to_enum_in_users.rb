class ConvertRoleToEnumInUsers < ActiveRecord::Migration[6.0]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    add_column :users, :role_temp, :integer, default: 0, null: false

    MigrationUser.reset_column_information
    MigrationUser.find_each do |user|
      role_value = case user[:role]
      when 'admin' then 1
      else 0
      end
      user.update_column(:role_temp, role_value)
    end

    remove_column :users, :role
    rename_column :users, :role_temp, :role
  end

  def down
    add_column :users, :role_temp, :string

    MigrationUser.reset_column_information
    MigrationUser.find_each do |user|
      role_value = case user[:role]
      when 1 then 'admin'
      else 'customer'
      end
      user.update_column(:role_temp, role_value)
    end

    remove_column :users, :role
    rename_column :users, :role_temp, :role
  end
end
