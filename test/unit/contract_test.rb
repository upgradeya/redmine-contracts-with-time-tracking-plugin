require File.expand_path('../../test_helper', __FILE__)

class ContractTest < ActiveSupport::TestCase
  fixtures  :contracts, :time_entries, :projects, :issues, 
            :user_contract_rates, :user_project_rates, 
            :users, :members, :member_roles

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @contract = contracts(:contract_one)
    @contract2 = contracts(:contract_two)
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
    @time_entry = time_entries(:time_entries_001)
    @time_entry.contract_id = @contract.id
    @time_entry.project_id = @project.id
    @time_entry.issue_id = @issue.id
    assert @time_entry.save
    @user = @project.users.first
  end

  test "should not save without project contract id" do
    @contract.project_contract_id = nil
    assert !@contract.save
  end

  test "project contract id should be unique" do
    @contract2.project_id = @contract.project_id
    @contract2.project_contract_id = @contract.project_contract_id
    assert !@contract2.save
  end

  test "project contract id should be more than 0" do
    @contract2.project_contract_id = -1
    assert !@contract2.save
    @contract2.project_contract_id = 0
    assert !@contract2.save
  end

  test "project contract id should be less than 1000" do
    @contract2.project_contract_id = 1000
    assert !@contract2.save
  end

  test "project contract id should be between 0 and 1000" do
    @contract2.project_contract_id = 444
    assert @contract2.save
  end

  test "should not save without start date" do
    @contract.start_date = nil
    assert !@contract.save
  end

  test "should save without end date" do
    @contract.end_date = nil
    assert @contract.save
  end

  test "should save without agreement date" do
    @contract.agreement_date = nil
    assert @contract.save
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
    @contract.agreement_date = @contract.start_date + 7
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

  test "should have members with time entries" do
    assert_equal @contract, @time_entry.reload.contract
    assert_equal 2, @time_entry.user.id
    assert_equal 1, @contract.time_entries.reload.size
    assert_equal [@time_entry.user], @contract.members_with_entries
  end

  test "should have a user project rate or default rate" do
    assert_equal @contract.hourly_rate.to_f, @contract.user_project_rate_or_default(@contract.project.users.first).to_f
  end

  test "should calculate total hours spent" do
    assert_equal @contract.hours_spent, @time_entry.hours
  end

  test "should calculate the billable amount for a contract based upon contractor-specific rates" do
    billable = @time_entry.hours * @contract.user_project_rate_or_default(@time_entry.user)
    @contract.billable_amount_total = @contract.calculate_billable_amount_total
    assert_equal billable, @contract.billable_amount_total
  end

  test "should calculate dollar amount remaining for contract" do
    @contract.billable_amount_total = @contract.calculate_billable_amount_total
    amount_remaining = @contract.purchase_amount - (@contract.billable_amount_total)
    assert_equal @contract.amount_remaining, amount_remaining
  end

  test "should set rates accessor" do
    rates = {"3"=>"27.00", "1"=>"35.00"}
    @contract.rates = rates
    assert_equal rates, @contract.rates
  end

  test "should apply rates to project's user project rates after save" do
    assert_equal 2, @project.users.size
    rate_hash = {}
    @project.users.each do |user|
      rate_hash[user.id.to_s] = '25.00'
    end
    @contract.rates = rate_hash
    @contract.project_id = @project.id
    assert @contract.save
    @project.users.each do |user|
      assert_equal 25.00, @project.rate_for_user(user)
    end
  end

  test "should have many user contract rates" do
    assert_respond_to @contract, :user_contract_rates
    assert_not_nil @user
    assert_equal 0, @contract.user_contract_rates.size
    ucr = @contract.user_contract_rates.create!(:user_id => @user.id, :rate => 37.50)
    assert_equal @user, ucr.user
    assert_equal 37.50, ucr.rate
  end

  test "should get a user project rate by user" do
    assert_not_nil @user
    ucr = @contract.user_contract_rates.create!(:user_id => @user.id, :rate => 48.00)
    assert_equal ucr, @contract.user_contract_rate_by_user(@user)
  end

  test "should get a rate for a user" do
    assert_not_nil @user
    @contract.user_contract_rates.create!(:user_id => @user.id, :rate => 25.00)
    assert_equal 25.00, @contract.rate_for_user(@user)
  end

  test "should set a user rate" do
    assert_not_nil @user
    assert_equal 0, @contract.user_contract_rates.size
    assert_nil @contract.user_contract_rate_by_user(@user)
    @contract.set_user_contract_rate(@user, 37.25)
    assert_equal 37.25, @contract.rate_for_user(@user)
  end

  test "should get a sum of contract expenses" do
    assert_equal 0, @contract.contracts_expenses.size
    assert_equal 0.0, @contract.expenses_total
    2.times do
      ContractsExpense.create!(:name => 'Foo', :expense_date => '2013-05-15', :amount => 1.11, :contract_id => @contract.id)
    end
    assert_equal 2, @contract.contracts_expenses.reload.size
    assert_equal 2.22, @contract.expenses_total
  end

end
