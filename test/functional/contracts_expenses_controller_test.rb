require File.expand_path('../../test_helper', __FILE__)

class ContractsExpensesControllerTest < ActionController::TestCase
  include Redmine::I18n
  fixtures :contracts, :projects, :users

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @contract = contracts(:contract_one)
    @project = projects(:projects_001)
    @user = users(:users_004)
    @contract.project_id = @project.id
    @request.session[:user_id] = @user.id
    @project.enabled_module_names = [:contracts]
  end

  test "should get new with permission" do
    Role.find(4).add_permission! :create_expenses
    get :new, :project_id => @project.id
    assert_response :success
    assert_not_nil assigns(:contracts_expense)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:contracts)
  end

  test "should create new expense with permission" do
    Role.find(4).add_permission! :create_expenses
    get :new, :project_id => @project.id, :contracts_expense => { :name => '' }
    assert_response :success
    assert_not_nil assigns(:contracts_expense)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:contracts)
  end

  test "should save valid expense" do
    Role.find(4).add_permission! :create_expenses
    post :create, :project_id => @project.id,
                  :contracts_expense => { :name => 'Domain name registration', :expense_date => '2013-05-31',
                                :amount => '10.25', :contract_id => @contract.id, :description => 'The description' }
    assert_response :redirect
    assert_equal 0, assigns(:contracts_expense).errors.size
    assert !assigns(:contracts_expense).new_record?
  end

  test "should not save expense with non-valid issue_id" do
    Role.find(4).add_permission! :create_expenses
    post :create, :project_id => @project.id,
                  :contracts_expense => { :name => '', :issue_id => -1 }
    assert_response :success
    assert_not_nil assigns(:contracts_expense).errors.messages[:issue_id]
  end

  test "should update valid expense" do
    Role.find(4).add_permission! :edit_expenses
    expense = ContractsExpense.create!(:name => 'Foo', :expense_date => '2013-05-15', :amount => 1, :contract_id => @contract.id)
    put :update, :project_id => @project.id, :id => expense.id,
                  :contracts_expense => { :name => 'Foo Updated', :expense_date => '2013-05-31',
                                :amount => '42.42', :contract_id => @contract.id, :description => 'desc' }
    assert_response :redirect
    assert_equal 'Foo Updated', assigns(:contracts_expense).name
    assert_equal 42.42, assigns(:contracts_expense).amount
    assert_equal 'desc', assigns(:contracts_expense).description
  end

  test "should not update invalid expense" do
    Role.find(4).add_permission! :edit_expenses
    expense = ContractsExpense.create!(:name => 'Foo', :expense_date => '2013-05-15', :amount => 1, :contract_id => @contract.id)
    put :update, :project_id => @project.id, :id => expense.id,
                  :contracts_expense => { :name => '', :expense_date => '2013-05-31',
                                :amount => '42.42', :contract_id => @contract.id, :description => 'desc' }
    assert_response :success
    assert_not_nil assigns(:contracts_expense).errors.messages[:name]
    assert_equal 'Foo', expense.reload.name
  end

  test "should destroy an expense" do
    Role.find(4).add_permission! :delete_expenses
    expense = ContractsExpense.create!(:name => 'Foo', :expense_date => '2013-05-15', :amount => 1, :contract_id => @contract.id)
    delete :destroy, :project_id => @project.id, :id => expense.id
    assert_response :redirect
    assert_nil ContractsExpense.where(:id => expense.id).first
  end

  test "should get error notice on new without permission" do
    get :new, :project_id => @project.id
    assert_response 403
    assert_nil assigns(:contracts_expense)
  end

  test "should get error notice on create without permission" do
    post :create, :project_id => @project.id
    assert_response 403
  end

  test "should get error notice on edit without permission" do
    get :edit, :project_id => @project.id, :id => 1
    assert_response 403
  end

  test "should get error notice on update without permission" do
    put :update, :project_id => @project.id, :id => 1, :contracts_expense => { :name => 'foo' }
    assert_response 403
  end

  test "should get error notice on destroy without permission" do
    delete :destroy, :project_id => @project.id, :id => 1
    assert_response 403
  end


end
