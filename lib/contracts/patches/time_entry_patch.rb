module Contracts
  require_dependency 'time_entry'

  module TimeEntryPatch
    def self.included(base)
      base.class_eval do 
        unloadable
        belongs_to :contract
        safe_attributes 'contract_id'
      end
    end
  end
  TimeEntry.send(:include, TimeEntryPatch)
end

