class AddContractIdToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :contract_id, :integer
  end
end
