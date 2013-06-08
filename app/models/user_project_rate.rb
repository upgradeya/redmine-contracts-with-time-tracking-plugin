class UserProjectRate < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :user
end
