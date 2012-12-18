module Contracts
  require_dependency 'project'

  module ProjectPatch
    def self.included(base)
      base.class_eval do 
        unloadable
        has_many :contracts
        base.send(:include, InstanceMethods)
      end
    end

    module InstanceMethods
      def total_amount_purchased
        self.contracts.sum { |contract| contract.purchase_amount }
      end

      def total_hours_purchased
        self.contracts.sum { |contract| contract.hours_purchased }
      end
      
      def total_amount_remaining
        self.contracts.sum { |contract| contract.amount_remaining }
      end

      def total_hours_remaining
        self.contracts.sum { |contract| contract.hours_remaining }
      end
    end

  end
  Project.send(:include, ProjectPatch)
end

