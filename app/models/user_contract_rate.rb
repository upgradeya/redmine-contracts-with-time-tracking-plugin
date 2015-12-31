class UserContractRate < ActiveRecord::Base
  unloadable
  belongs_to :contract
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :contract_id
end
