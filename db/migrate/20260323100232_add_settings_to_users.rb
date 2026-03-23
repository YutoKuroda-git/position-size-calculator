class AddSettingsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :account_balance, :decimal, precision: 15, scale: 2, default: 100000.00
    add_column :users, :risk_percent, :decimal, precision: 5, scale: 2, default: 1.00
  end
end
