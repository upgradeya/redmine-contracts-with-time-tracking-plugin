class AddFixedPriceContract < ActiveRecord::Migration
  def change
    add_column :contracts, :is_fixed_price, :boolean, :default => false
    Contract.update_all( :is_fixed_price => false )
  end
end
