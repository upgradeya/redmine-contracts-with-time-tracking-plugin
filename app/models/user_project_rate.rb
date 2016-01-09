class UserProjectRate < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :project_id
end
