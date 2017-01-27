require_dependency 'time_entry'

module Contracts

  module TimeEntryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        belongs_to :contract
        safe_attributes 'contract_id'
        after_update :refresh_contract
        after_destroy :refresh_contract
        after_create :refresh_contract

        attr_accessor :flash_time_entry_success, :flash_only_one_time_entry

        validate :time_not_exceed_contract
        before_save :create_next_contract

        # Validate the "hours" input field for hourly contracts.
        #
        # Validate that the hours entered do not exceed the hours remaining on a contract.
        # If "auto create new contract" settings option is enabled, use this validation to
        # ensure the hours entered does not exceed the hours remaining plus the size of a
        # new contract.
        protected
        def time_not_exceed_contract
          return if hours.blank?
          return if contract.is_fixed_price
          previous_hours = (hours_was != nil) ? hours_was : 0 

          if contract_id != nil
            if Setting.plugin_contracts['automatic_contract_creation']
              if hours > (contract.hours_remaining + contract.hours_purchased + previous_hours)
                errors.add :hours, l(:text_hours_too_large)
              end
            else
              if hours > (contract.hours_remaining + previous_hours)
                errors.add :hours, l(:text_invalid_hours, :title => contract.title, :hours => l_hours(contract.hours_remaining + previous_hours))
              end
            end
          end
        end


        # Create new contract if it is an hourly contract, and the settings configuration
        # is enabled and the hours exceed the current contract.
        private
        def create_next_contract
          return if contract.is_fixed_price
          previous_hours = (hours_was != nil) ? hours_was : 0
          if Setting.plugin_contracts['automatic_contract_creation'] && hours > (contract.hours_remaining + previous_hours)
            new_contract = Contract.new
            new_contract.project_contract_id = Project.find(contract.project_id).contracts.last.project_contract_id + 1
            new_contract.category_id = contract.category_id
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

              # split the time entry and save new entry in the new contract
              new_time_entry = TimeEntry.new
              new_time_entry.project_id = project_id
              new_time_entry.issue_id = issue_id
              new_time_entry.user_id = user.id
              new_time_entry.hours = hours - (contract.hours_remaining + previous_hours)
              new_time_entry.comments = comments
              new_time_entry.activity_id = activity_id
              new_time_entry.spent_on = spent_on
              new_time_entry.contract_id = new_contract.id

              if new_time_entry.save
                self.flash_time_entry_success = true
                self.hours = contract.hours_remaining + previous_hours

                # @TODO This is not working. Its supposed to create a different error message
                # if there are zero remaining hours in the current contract
                if self.hours <= 0.1 && self.hours >= -0.1
                  self.flash_only_one_time_entry
                end
              else
                logger.error "Split time entry ran into errors"
                logger.error new_time_entry.errors.full_messages.join("\n")
                errors.add :contract_id, l(:text_second_time_entry_failure, :error => new_time_entry.errors.full_messages.join("\n"))
                return false
              end
            else
              logger.error "New auto created contract ran into errors"
              logger.error new_contract.errors.full_messages.join("\n")
              errors.add :contract_id, l(:text_auto_contract_failure, :error => new_contract.errors.full_messages.join("\n"))
              return false
            end
          else
            # Do nothing. Configuration is off or contract hours not exceeded.
          end
        end
      end
    end

    module InstanceMethods

      def refresh_contract
        return if self.contract_id.nil?
        the_contract = Contract.find(self.contract_id)
        the_contract.reset_cache!
      end
    end
  end
end

