module ContractsHelper

  def expense_edit_urlpath(contract, expense)
    { :controller => 'contracts_expenses', :action => 'edit', :project_id => contract.project.identifier, :id => expense.id }
  end

  def format_hours(hours)
    format("%#.2f", hours)
  end

  def tab_selected
    raw 'class="selected"'
  end

  def span_required
    raw '<span class="required"> *</span>'
  end

  # Returns a collection of categories for a select field.  contract
  # is optional and will be used to check if the selected ContractCategory
  # is active.
  def contract_category_collection_for_select_options(contract=nil)
    categories = ContractCategory.shared.active

    collection = []
    if contract && contract.category && !contract.category.active?
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
    else
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ] unless categories.detect(&:is_default)
    end
    categories.each { |a| collection << [a.name, a.id] }
    collection
  end

end
