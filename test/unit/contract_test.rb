require File.expand_path('../../test_helper', __FILE__)

class ContractTest < ActiveSupport::TestCase
  fixtures :contracts, :time_entries, :projects, :issues

  def setup
    @contract = contracts(:contract_one)
    @contract2 = contracts(:contract_two)
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
    @time_entry = time_entries(:time_entries_001)
    @time_entry.contract_id = @contract.id
    @time_entry.project_id = @project.id
    @time_entry.issue_id = @issue.id
    assert @time_entry.save
  end
  
  test "should not save without title" do
    @contract.title = '' 
    assert !@contract.save
  end

  test "title should be unique" do
    @contract2.title = @contract.title
    assert !@contract2.save
    @contract2.title = @contract.title.downcase
    assert !@contract2.save
  end

  test "should not save without start date" do
    @contract.start_date = nil
    assert !@contract.save
  end

  test "should not save without end date" do
    @contract.end_date = nil
    assert !@contract.save
  end

  test "should not save without agreement date" do
    @contract.agreement_date = nil
    assert !@contract.save
  end
  
  test "should not save without hourly rate" do
    @contract.hourly_rate = nil
    assert !@contract.save
  end

  test "should not save without purchase amount" do
    @contract.purchase_amount = nil
    assert !@contract.save
  end

  test "should not save without project id" do
    @contract.project_id = nil
    assert !@contract.save
  end

  test "agreement date can come after start date" do
    @contract.start_date = @contract.agreement_date - 7
    assert @contract.save
  end
  
  test "start date should come before end date" do
    @contract.end_date = @contract.start_date - 7
    assert !@contract.save
  end

  test "should have time entries" do
    assert_respond_to @contract, "time_entries"
    assert_equal @contract.time_entries.count, 1
  end

  test "should calculate total hours spent" do
    assert_equal @contract.hours_spent, @time_entry.hours
  end

  test "should calculate dollar amount remaining for contract" do
    amount_remaining = @contract.purchase_amount - (@contract.hours_spent * @contract.hourly_rate)
    assert_equal @contract.amount_remaining, amount_remaining
  end

	test "should return message if time entry exceeds amount remaining" do
		contract = contracts(:contract_three)
		hours = (contract.amount_remaining / contract.hourly_rate) + 10
		hours_over = contract.exceeds_remaining_hours_by?(hours)
		assert_equal 10.0, hours_over
	end
end
