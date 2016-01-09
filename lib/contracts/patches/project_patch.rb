require_dependency 'project'

module Contracts
  module ProjectPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        has_many :contracts
        has_many :user_project_rates
      end
    end

    module InstanceMethods

      def unlocked_contracts
        contracts.select { |contract| !contract.is_locked }
      end

      def user_project_rate_by_user(user)
        self.user_project_rates.select { |upr| upr.user_id == user.id}.first
      end

      def rate_for_user(user)
        upr = self.user_project_rate_by_user(user)
        upr.nil? ? 0.0 : upr.rate
      end

      def set_user_rate(user, rate)
        upr = user_project_rate_by_user(user)
        if upr.nil?
          self.user_project_rates.create!(:user_id => user.id, :rate => rate)
        else
          upr.update_attribute(:rate, rate)
          upr
        end
      end

      def total_amount_purchased
        self.contracts.map(&:purchase_amount).inject(0, &:+)
      end

      def total_hours_purchased
        self.contracts.map(&:hours_purchased).inject(0, &:+)
      end

      def total_amount_remaining
        self.contracts.map(&:amount_remaining).inject(0, &:+)
      end

      def total_hours_remaining
        self.contracts.map(&:hours_remaining).inject(0, &:+)
      end

      def contracts_for_all_ancestor_projects(contracts=self.contracts)
        if self.parent != nil
          parent = self.parent
          contracts +=  parent.contracts_for_all_ancestor_projects
        end
        return contracts
      end

      def unlocked_contracts_for_all_ancestor_projects(contracts = self.unlocked_contracts)
        if self.parent != nil
          parent = self.parent
          contracts += parent.unlocked_contracts_for_all_ancestor_projects
        end
        return contracts
      end

      def time_entries_for_all_descendant_projects(time_entries=self.time_entries)
        if self.children != nil
          self.children.each { |child| time_entries += child.time_entries_for_all_descendant_projects }
        end
        return time_entries
      end
    end
  end
end

