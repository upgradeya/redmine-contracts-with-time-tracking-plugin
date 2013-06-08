module ContractsHelper

  def expense_edit_urlpath(contract, expense)
    "/projects/#{contract.project.identifier}/expenses/#{expense.id}/edit"
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
end
