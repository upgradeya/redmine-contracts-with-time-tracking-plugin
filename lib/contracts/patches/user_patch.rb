module Contracts
  require_dependency 'user'

  module UserPatch
    def self.included(base)
      base.class_eval do
        unloadable
        has_many :user_project_rates
        has_many :user_contract_rates
      end
    end

  end
  User.send(:include, UserPatch)
end

