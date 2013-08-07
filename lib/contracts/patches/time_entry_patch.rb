module Contracts
  require_dependency 'time_entry'

  module TimeEntryPatch
    def self.included(base)
      base.class_eval do 
        unloadable
        belongs_to :contract
        safe_attributes 'contract_id'
        after_update :refresh_contract
        after_destroy :refresh_contract
        after_create :refresh_contract

        base.send(:include, InstanceMethods)
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
  TimeEntry.send(:include, TimeEntryPatch)
end

