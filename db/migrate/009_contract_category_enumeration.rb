class ContractCategoryEnumeration < ActiveRecord::Migration
  	def change
    	add_column :contracts, :category_id, :integer

    	# Add a few default categories here
    	category1 = ContractCategory.new
    	category1.name = "Dev"
    	category1.position = 1
    	category1.type = ContractCategory
    	category1.save

    	category2 = ContractCategory.new
    	category2.name = "Maint"
    	category2.position = 2
    	category2.type = ContractCategory
    	category2.save
	end
end