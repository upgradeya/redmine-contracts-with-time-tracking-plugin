class Expense < ActiveRecord::Base
  unloadable
  belongs_to :contract
  belongs_to :issue
  validates_presence_of :name, :expense_date, :amount, :contract_id
  validates :amount, :numericality => { :greater_than => 0 }

  validate :issue_exists

  after_create :expire_contract_fragment!
  after_save :expire_contract_fragment!
  before_destroy :expire_contract_fragment!

  def issue_exists
    return true if self.issue_id.blank?
    if self.issue.nil?
      errors.add(:issue_id, l(:text_invalid_issue_id))
    end
  end

  private

    def expire_contract_fragment!
      self.contract.expire_fragment!
    end

end
