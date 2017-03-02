class AddRecurringContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :recurring_frequency, :integer, :default => 0
  end
end
