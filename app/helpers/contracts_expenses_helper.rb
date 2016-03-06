module ContractsExpensesHelper

  def expense_edit_urlpath(contract, expense)
    "/projects/#{contract.project.identifier}/expenses/#{expense.id}/edit"
  end

  def span_required
    raw '<span class="required"> *</span>'
  end
end
