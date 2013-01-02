class Contract < ActiveRecord::Base
  unloadable
  belongs_to :project 
  has_many   :time_entries
  validates_presence_of :title, :start_date, :end_date, :agreement_date, 
                        :purchase_amount, :hourly_rate, :project_id
  validates :title, :uniqueness => { :case_sensitive => false }
  #validates :start_date, :is_after_agreement_date => true
  validates :end_date, :is_after_start_date => true
  before_destroy { |contract| contract.time_entries.clear }
  

  def hours_purchased
    self.purchase_amount / self.hourly_rate
  end
  
  def hours_spent
    self.time_entries.sum { |time_entry| time_entry.hours }
  end
  
  def amount_remaining
    self.purchase_amount - (self.hours_spent * self.hourly_rate)
  end

  def hours_remaining
    self.hours_purchased - self.hours_spent
  end

  private
    
    def remove_contract_id_from_associated_time_entries
      self.time_entries.each do |time_entry|
        time_entry.contract_id = nil
        time_entry.save
      end
    end
end
