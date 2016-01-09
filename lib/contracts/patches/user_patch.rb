require_dependency 'user'

module Contracts

  module UserPatch
    def self.included(base)
      base.class_eval do
        has_many :user_project_rates
        has_many :user_contract_rates
      end
    end
  end
end

