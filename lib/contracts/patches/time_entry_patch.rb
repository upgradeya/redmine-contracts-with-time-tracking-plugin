module Contracts
  require_dependency 'time_entry'

  module TimeEntryPatch
    def self.included(base)
      base.class_eval do 
        unloadable
        belongs_to :contract
        safe_attributes 'contract_id'

        validate :time_not_exceed_contract
        before_save :create_next_contract

        # Validate the "hours" input field
        #
        # Validate that the hours entered do not exceed the hours remaining on a contract
        # If "auto create new contract" settings option is enabled, use this validation to
        # ensure the hours entered does not exceed the hours remaining plus the size of a
        # new contract.
        protected
        def time_not_exceed_contract
          if contract_id != nil && hours != nil
            if Setting.plugin_contracts['automatic_contract_creation']
              if hours > (contract.hours_remaining + contract.hours_purchased)
                errors.add :hours, "is invalid. The amount exceeds the time remaining plus the size of a new contract."
              end
            else
              if hours > contract.hours_remaining
                errors.add :hours, "is invalid. The contract " + contract.title + " only has " + contract.hours_remaining.to_s + " hours remaining."
              end
            end
          end
        end


        # Create new contract if the settings configuration is enabled and the hours exceed the current contract
        private
        def create_next_contract
          if Setting.plugin_contracts['automatic_contract_creation'] && hours > contract.hours_remaining
            new_contract = Contract.new
            new_contract.title = project.identifier + "_Dev#" + ("%03d" % (project.contracts.last.id + 1))
            new_contract.description = contract.description
            new_contract.start_date = Time.new
            new_contract.hourly_rate = contract.hourly_rate
            new_contract.purchase_amount = contract.purchase_amount
            new_contract.contract_url = ""
            new_contract.invoice_url = ""
            new_contract.project_id = contract.project_id

            # add the contractors and rates
            contractors = Contract.users_for_project_and_sub_projects(project)
            contractor_rates = {}
            contractors.each do |contractor|
              if contract.new_record?
                rate = project.rate_for_user(contractor)
              else
                rate = contract.user_contract_rate_or_default(contractor)
              end
              contractor_rates[contractor.id] = rate
            end

            new_contract.rates = contractor_rates

            if new_contract.save

              # split the time entry and save in the new contract
              new_time_entry = TimeEntry.new
              new_time_entry.project_id = project_id
              new_time_entry.issue_id = issue_id
              new_time_entry.user_id = user.id
              new_time_entry.hours = hours - contract.hours_remaining
              new_time_entry.comments = comments
              new_time_entry.activity_id = activity_id
              new_time_entry.spent_on = spent_on
              new_time_entry.contract_id = new_contract.id

              if new_time_entry.save
                self.hours = contract.hours_remaining
              else
                logger.error "Split time entry ran into errors"
                logger.error new_time_entry.errors.full_messages.join("\n")
                errors.add :contract_id, "something went wrong. The 2nd entry for this split time entry could not be saved. " +
                   new_time_entry.errors.full_messages.join("\n")
                  return false
              end
            else
              logger.error "New auto created contract ran into errors"
              logger.error new_contract.errors.full_messages.join("\n")
              errors.add :contract_id, "something went wrong. The new contract for this split time entry could not be saved. " +
                   new_contract.errors.full_messages.join("\n")
              return false
            end
          else
            # Do nothing. Configuration is off or contract hours not exceeded.
          end
        end
      end
    end
  end
  TimeEntry.send(:include, TimeEntryPatch)
end

