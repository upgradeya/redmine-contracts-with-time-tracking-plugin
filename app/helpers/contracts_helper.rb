module ContractsHelper

  def expense_edit_urlpath(contract, expense)
    { :controller => 'expenses', :action => 'edit', :project_id => contract.project.identifier, :id => expense.id }
  end

  def has_project_permissions?(project, permission)
    User.current.roles_for_project(project).first.permissions.include?(permission)
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

end
