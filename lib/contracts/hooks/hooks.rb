module Contracts
  class ContractsHookListener < Redmine::Hook::ViewListener
  
    def view_timelog_edit_form_bottom(context={})
      if context[:time_entry].project_id != nil
        @current_project = Project.find(context[:time_entry].project_id)
        @contracts = @current_project.contracts_for_all_ancestor_projects

        if !@contracts.empty?
          if context[:time_entry].contract_id != nil
            selected_contract = context[:time_entry].contract_id
          elsif !(@current_project.contracts.empty?)
            selected_contract = @current_project.contracts.maximum(:id)
          elsif !(@contracts.empty?)
            selected_contract = @contracts.max_by(&:id).id
          else
            selected_contract = ''
          end
          contract_unselectable = false
          if !selected_contract.blank?
            # There is a selected contract. Check to see if it has been locked
            selected_contract_obj = Contract.find(selected_contract)
            if selected_contract_obj.is_locked
              # Contract has been locked. Only list that contract in the drop-down
              @contracts = [selected_contract_obj]
              contract_unselectable = true
            else
              # Only show NON-locked contracts in the drop-down
              @contracts = @current_project.unlocked_contracts_for_all_ancestor_projects
            end
          else
            # There is NO selected contract. Only show NON-locked contracts in the drop-down
            @contracts = @current_project.unlocked_contracts_for_all_ancestor_projects
          end
          db_options = options_from_collection_for_select(@contracts, :id, :title, selected_contract)
          no_contract_option = "<option value=''>-- #{l(:label_contract_empty)} -- </option>\n".html_safe
          if !contract_unselectable
            all_options = no_contract_option << db_options
          else
            # Contract selected has already been locked. Do not show the [Select Contract] label.
            all_options = db_options
          end
          select = context[:form].select :contract_id, all_options
          return "<p>#{select}</p>"
        end
      else
        "<p>This page will not work due to the contracts plugin. You must log time entries from within a project."
      end
    end
  end
end
