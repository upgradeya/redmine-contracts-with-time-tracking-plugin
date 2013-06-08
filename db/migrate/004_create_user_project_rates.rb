class CreateUserProjectRates < ActiveRecord::Migration
  def change
    create_table :user_project_rates do |t|
      t.integer :user_id
      t.integer :project_id
      t.float :rate, :length => 8, :decimals => 2
    end
  end
end
