require File.expand_path('../../test_helper', __FILE__)

class ExpenseTest < ActiveSupport::TestCase
  self.fixture_path = File.expand_path('../../fixtures', __FILE__)
  fixtures :contracts, :issues

  def setup
    @contract = contracts(:contract_one)
    #@project = projects(:projects_001)
    @issue = issues(:issues_001)
    #@user = @project.users.first
    @expense = build_valid_expense
  end

  test "should save a valid expense" do
    assert @expense.save
  end

  test "should not save without name" do
    @expense.name = ''
    assert !@expense.save
  end

  test "should not save without expense date" do
    @expense.expense_date = nil
    assert !@expense.save
  end

  test "should not save without amount" do
    @expense.amount = nil
    assert !@expense.save
  end

  test "should not save without a contract" do
    @expense.contract_id = nil
    assert !@expense.save
  end

  test "should not save unless amount is greater than zero" do
    @expense.amount = -0.01
    assert !@expense.save
    @expense.amount = 0.01
    assert @expense.save
  end

  def build_valid_expense
    Expense.new(:name => 'Domain name purchase', :expense_date => Date.today, :amount => 12.98, :contract_id => @contract.id)
  end
end
