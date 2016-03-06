class RenameExpenses < ActiveRecord::Migration
  def change
    rename_table :expenses, :contracts_expenses
  end
end