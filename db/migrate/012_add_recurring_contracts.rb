class AddRecurringContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :recurring_frequency, :integer, :default => 0
    add_column :contracts, :series_id, :integer
  end
end
