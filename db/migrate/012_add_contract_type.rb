class AddContractType < ActiveRecord::Migration
  def change
    add_column :contracts, :contract_type, :string
    Contract.where('is_fixed_price LIKE 1').update_all( :contract_type => 'fixed' )
    Contract.where('is_fixed_price LIKE 0').update_all( :contract_type => 'hourly' )
  end
end
