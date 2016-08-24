=begin
 This file used to create the expenses table
 but it was in conflict with several other
 plugins that also had an expense table.
 The create expenses table migration has
 moved to 010_rename_expenses.rb and the
 table name is now contracts_expenses.
=end

class CreateExpenses < ActiveRecord::Migration

end
