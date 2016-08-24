=begin
 This file is used to create the
 contracts_expenses table
=end

class RenameExpenses < ActiveRecord::Migration
  def change
    create_table :contracts_expenses do |t|
      t.string :name
      t.date :expense_date
      t.float :amount, :length => 8, :decimals => 2
      t.integer :contract_id
      t.integer :issue_id
      t.string :description
    end
  end
end
