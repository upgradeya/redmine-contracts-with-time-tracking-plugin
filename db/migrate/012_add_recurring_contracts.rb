class AddRecurringContracts < ActiveRecord::Migration
  def change
  	add_column :contracts, :is_recurring, :boolean, :default => false
    add_column :contracts, :recurring_frequency, :string, :default => 'not'
  end
end
