class ProjectContractId < ActiveRecord::Migration
  def change
    add_column :contracts, :project_contract_id, :integer, :default => 1
    Contract.reset_column_information
    Project.all.each do |project|
      # loop thru each project assigning ids to each contract
      id = 1;
      project.contracts.each do |contract|
    	contract.update_attributes(:project_contract_id => id)
    	id += 1;
      end
    end
  end
end
