class UserContractRate < ActiveRecord::Base
  belongs_to :contract
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :contract_id
end
