class ContractsExpense < ActiveRecord::Base
  belongs_to :contract
  belongs_to :issue
  validates_presence_of :name, :expense_date, :amount, :contract_id
  validates :amount, :numericality => { :greater_than => 0 }

  validate :issue_exists
 
  def issue_exists
    return true if self.issue_id.blank?
    if self.issue.nil?
      errors.add(:issue_id, l(:text_invalid_issue_id))
    end
  end
end
