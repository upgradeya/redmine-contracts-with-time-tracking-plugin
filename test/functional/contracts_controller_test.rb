require File.expand_path('../../test_helper', __FILE__)

class ContractsControllerTest < ActionController::TestCase
  include Redmine::I18n
  
  fixtures :issues, :projects, :users, :time_entries,
           :members, :roles, :member_roles,
           :trackers, :issue_statuses,
           :journals, :journal_details,
           :issue_categories, :enumerations,
           :groups_users,
           :enabled_modules,
           :workflows,
           :contracts, :user_contract_rates, :user_project_rates

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @contract = contracts(:contract_one)
    @project = projects(:projects_001)
    @user = users(:users_004)
    @time_entry = time_entries(:time_entries_002)
    @contract.project_id = @project.id
    @request.session[:user_id] = @user.id
    @project.enabled_module_names = [:contracts]
  end

  test "should get index with permission" do
    Role.find(4).add_permission! :view_all_contracts_for_project
    get :index, :project_id => @project.id
    assert_response :success
    assert_not_nil assigns(:contracts)
    assert_not_nil assigns(:total_purchased_dollars)
    assert_not_nil assigns(:total_purchased_hours)
    assert_not_nil assigns(:total_remaining_dollars)
    assert_not_nil assigns(:total_remaining_hours)
  end

  test "should not get index without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:view_all_contracts_for_project)
    get :index, :project_id => @project.id
    assert_response 403
  end

  test "should get new with permission" do
    Role.find(4).add_permission! :create_contracts
    get :new, :project_id => @project.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:contractors)
  end

  test "should not get new without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:create_contracts)
    get :new, :project_id => @project.id
    assert_response 403
  end

test "should create new contract with permission" do
    Role.find(4).add_permission! :create_contracts
    assert_difference('Contract.count') do
      post :create, :project_id => @project.identifier,
                   :contract => { :title => "New Title",
                                  :description => @contract.description,
                                  :start_date => @contract.start_date,
                                  :purchase_amount => @contract.purchase_amount,
                                  :hourly_rate => @contract.hourly_rate,
                                  :project_id => @project.id,
                                  :project_contract_id => @contract.project_contract_id + 12
                                }
    end
    assert_not_nil assigns(:contract)
    assert_redirected_to :action => "show", :project_id => @project.identifier, :id => assigns(:contract)
  end

  test "should not create new contract without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:create_contracts)
    assert_no_difference('Contract.count') do
      post :create, :project_id => @project.identifier,
                   :contract => { :title => "New Title",
                                  :description => @contract.description,
                                  :agreement_date => @contract.agreement_date,
                                  :start_date => @contract.start_date,
                                  :end_date => @contract.end_date,
                                  :purchase_amount => @contract.purchase_amount,
                                  :hourly_rate => @contract.hourly_rate,
                                  :project_id => @project.id
                                }
    end
  end

  test "should get show with permission" do
    Role.find(4).add_permission! :view_contract_details
    get :show, :project_id => @project.id, :id => @contract.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:time_entries)
    assert_not_nil assigns(:members)
  end

  test "should get show and assign all user who've logged time to contributers" do
    Role.find(4).add_permission! :view_contract_details
    @time_entry.contract_id = @contract.id
    @time_entry.save
    get :show, :project_id => @project.id, :id => @contract.id
    assert assigns(:members).include?(@time_entry.user)
  end

  test "should not get show without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:view_contract_details)
    get :show, :project_id => @project.id, :id => @contract.id
    assert_response 403
  end

  test "should get edit with permission" do
    Role.find(4).add_permission! :edit_contracts
    get :edit, :project_id => @project.id, :id => @contract.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:projects)
  end

  test "should not get edit without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:edit_contracts)
    get :edit, :project_id => @project.id, :id => @contract.id
    assert_response 403
  end

  test "should update contract with permission" do
    Role.find(4).add_permission! :edit_contracts
    @contract.save
    assert_no_difference('Contract.count') do
      put :update, :project_id => @project.id, :id => @contract.id,
          :contract => {  :title => @contract.title,
                          :description => @contract.description,
                          :agreement_date => @contract.agreement_date,
                          :start_date => @contract.start_date,
                          :end_date => @contract.end_date,
                          :purchase_amount => @contract.purchase_amount,
                          :hourly_rate => @contract.hourly_rate,
                          :project_id => @contract.project_id
                        },
          :rates => { @user.id => '37.50'}
    end
    assert_redirected_to :action => "show", :project_id => @project.id, :id => assigns(:contract).id
    assert_equal 37.5, assigns(:contract).project.rate_for_user(@user).to_f
  end

  test "should not update contract without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:edit_contracts)
    put :update, :project_id => @project.id, :id => @contract.id,
        :contract => {  :title => @contract.title,
                        :description => @contract.description,
                        :agreement_date => @contract.agreement_date,
                        :start_date => @contract.start_date,
                        :end_date => @contract.end_date,
                        :purchase_amount => @contract.purchase_amount,
                        :hourly_rate => @contract.hourly_rate,
                        :project_id => @contract.project_id
                      }
    assert_response 403
  end

  test "should get all contracts" do
    get :all
    assert_response :success
    assert_not_nil assigns(:contracts)
    assert_not_nil assigns(:total_purchased_dollars)
    assert_not_nil assigns(:total_purchased_hours)
    assert_not_nil assigns(:total_remaining_dollars)
    assert_not_nil assigns(:total_remaining_hours)
  end

  test "should destroy contract with permission" do
    Role.find(4).add_permission! :delete_contracts
    assert_difference('Contract.count', -1) do
      delete :destroy, :project_id => @project.id, :id => @contract.id
    end
  end

  test "should not destroy contract without permission" do
    assert !@user.roles_for_project(@project).first.permissions.include?(:delete_contracts)
    delete :destroy, :project_id => @project.id, :id => @contract.id
    assert_response 403
  end

  test "should get 'add time entries' with permission" do
    Role.find(4).add_permission! :edit_contracts
    get :add_time_entries, :project_id => @project.id, :id => @contract.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:time_entries)
  end

  test "should not get 'add time entries' without permission" do
    get :add_time_entries, :project_id => @project.id, :id => @contract.id
    assert_response 403
  end

  test "should be able to associate time entries with contracts with permission" do
    Role.find(4).add_permission! :edit_contracts
    put :assoc_time_entries_with_contract, :project_id => @contract.project_id, :id => @contract.id,
          :time_entries => [[@time_entry.id]]
    assert_redirected_to :action => "show", :project_id => @contract.project_id, :id => @contract.id
  end

  test "should not be able to associate time entries with contracts without permission" do
    put :assoc_time_entries_with_contract, :project_id => @project.id, :id => @contract.id,
          :time_entries => [[@time_entry.id]]
    assert_response 403
  end
end
