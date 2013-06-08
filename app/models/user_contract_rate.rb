class UserContractRate < ActiveRecord::Base
  unloadable
  belongs_to :contract
  belongs_to :user
end
