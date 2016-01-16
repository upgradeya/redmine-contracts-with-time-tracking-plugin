class ContractCategory < Enumeration
  has_many :contracts, :foreign_key => 'category_id'

  OptionName = :enumeration_contract_categories

  def option_name
    OptionName
  end

  def objects_count
    contracts.count
  end

  def transfer_relations(to)
    contracts.update_all(:category_id => to.id)
  end
end
