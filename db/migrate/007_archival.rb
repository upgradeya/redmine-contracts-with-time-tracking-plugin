class Archival < ActiveRecord::Migration
  def change
    add_column :contracts, :is_archived, :boolean, :default => false
    add_column :contracts, :hours_worked, :float, :length => 8, :decimals => 2
    add_column :contracts, :billable_amount_total, :float, :length => 8, :decimals => 2
    Contract.update_all( :is_archived => false )
  end
end
