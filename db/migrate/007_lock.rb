class Lock < ActiveRecord::Migration
  def change
    add_column :contracts, :is_locked, :boolean, :default => false
    add_column :contracts, :hours_worked, :float, :length => 8, :decimals => 2
    add_column :contracts, :billable_amount_total, :float, :length => 8, :decimals => 2
    Contract.update_all( :is_locked => false )
  end
end
