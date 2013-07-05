class AddIndexes < ActiveRecord::Migration
  def change
    add_index :contracts, [:project_id]
    add_index :expenses, [:contract_id]
    add_index :time_entries, [:contract_id]
    add_index :user_contract_rates, [:contract_id]
  end
end
