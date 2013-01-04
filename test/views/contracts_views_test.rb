require File.expand_path('../../test_helper', __FILE__)

class ContractsControllerTest < ActionController::TestCase
  include ActionView::Helpers::NumberHelper
  fixtures :contracts, :projects, :users, :time_entries

  def setup 
    @contract 		= contracts(:contract_one)
    @project 			= projects(:projects_001)
 	 	@user 				= users(:users_004)
		@contract.project_id = @project.id
    @request.session[:user_id] = @user.id
    @project.enabled_module_names = [:contracts]
  end

  test "index view without 'view hourly rate', 'create contracts', and 'delete contracts' permissions" do 
		Role.find(4).add_permission! :view_all_contracts_for_project
    get :index, :project_id => @project.id
    assert_response :success
    
    assert_select 'h2', "Contracts"
		
		assert_tag :tag => "table", :attributes => { :class => "contracts-summary" }
    assert_tag :tag => "h3", :content => "Total Purchased for All Contracts" 
    assert_tag :tag => "h3", :content => "Total Remaining for All Contracts" 
		assert_tag :tag => "p", :attributes => { :class => "bigbold" }, :content => "#{number_to_currency(@project.total_amount_purchased)}"
		assert_tag :tag => "p", :attributes => { :class => "bigbold" }, :content => "~#{@project.total_hours_purchased.round(2)} hrs"
		assert_tag :tag => "p", :attributes => { :class => "green bigbold" }, :content => "#{number_to_currency(@project.total_amount_remaining)}"
		
		assert_tag :tag => "p", :attributes => { :class => "blue bigbold" }, :content => "~#{@project.total_hours_remaining.round(2)} hrs"
    assert_tag :tag => "table", :attributes => { :class => "contracts-list list" }
    assert_tag :tag => "th", :content => "Name"
    assert_tag :tag => "th", :content => "Agreed On"
    assert_tag :tag => "th", :content => "Date Range"
    assert_tag :tag => "th", :content => "Purchased"
    assert_tag :tag => "th", :content => "Remaining"
    assert_tag :tag => "th", :content => "Hours Worked"
    assert_tag :tag => "th", :content => "Remaining"
    assert_tag :tag => "th", :content => "Contract"
    assert_tag :tag => "th", :content => "Invoice"
    assert_tag :tag => "a", :content => "Sample Contract"

    assert_no_tag :tag => "a", :content => "New Contract"
		assert_no_tag :tag => "th", :content => "Hourly Rate"
		assert_no_tag :tag => "a", :attributes => { :title => "Edit" }
		assert_no_tag :tag => "a", :attributes => { :title => "Delete" }
  end

	test "index view with 'hourly rate' permission" do
		Role.find(4).add_permission! :view_all_contracts_for_project
		Role.find(4).add_permission! :view_hourly_rate
    get :index, :project_id => @project.id
    assert_response :success
		assert_tag :tag => "th", :content => "Hourly Rate"
	end 

	test "index view with 'create contracts' permission" do
		Role.find(4).add_permission! :view_all_contracts_for_project
		Role.find(4).add_permission! :create_contracts
    get :index, :project_id => @project.id
    assert_response :success
    assert_tag :tag => "a", :content => "New Contract"
	end 

	test "index view with 'edit contracts' permission" do
		Role.find(4).add_permission! :view_all_contracts_for_project
		Role.find(4).add_permission! :edit_contracts
    get :index, :project_id => @project.id
    assert_response :success
		assert_tag :tag => "a", :attributes => { :title => "Edit" }
	end 

	test "index view with 'delete contracts' permission" do
		Role.find(4).add_permission! :view_all_contracts_for_project
		Role.find(4).add_permission! :delete_contracts
    get :index, :project_id => @project.id
    assert_response :success
		assert_tag :tag => "a", :attributes => { :title => "Delete" }
	end 

  test "new view" do
		Role.find(4).add_permission! :create_contracts
    get :new, :project_id => @project.id
    assert_response :success
    assert_select "h2", "New Contract"
    assert_template :partial => "_form"

    assert_tag :tag => "form", :attributes => { :class => "new_contract" }
    assert_tag :tag => "input", :attributes => { :id => "contract_title" }
    assert_tag :tag => "textarea", :attributes => { :id => "contract_description" }
    assert_tag :tag => "select", :attributes => { :id => "contract_agreement_date_1i" }
    assert_tag :tag => "select", :attributes => { :id => "contract_start_date_1i" }
    assert_tag :tag => "select", :attributes => { :id => "contract_end_date_1i" }
    assert_tag :tag => "input", :attributes => { :id => "contract_purchase_amount" }
    assert_tag :tag => "input", :attributes => { :id => "contract_hourly_rate" }
    assert_tag :tag => "input", :attributes => { :id => "contract_project_id" }
    assert_tag :tag => "input", :attributes => { :type => "submit" }
  end

  test "show view without 'edit contracts' or 'delete contracts' permissions" do
		Role.find(4).add_permission! :view_contract_details
    get :show, :project_id => @project.id, :id => @contract.id
    assert_select "h2", "#{@contract.title}"
		assert_tag :tag => "table", :attributes => { :class => "contract-summary list" }
    assert_tag :tag => "p", :content => "#{@contract.description}"
    assert_tag :tag => "th", :content => "Agreement Date"
    assert_tag :tag => "th", :content => "Date Range"
    assert_tag :tag => "th", :content => "Amount Purchased"

		assert_tag :tag => "table", :attributes => { :class => "hours-summary list"}
		assert_tag :tag => "th", :content => "Member"
		assert_tag :tag => "th", :content => "Hours"
    
		assert_tag :tag => "h3", :content => "Time Entries"
    assert_tag :tag => "table", :attributes => { :class => "time-entries-for-contract-list list" }

    assert_no_tag :tag => "p", :content => "Hourly Rate"
		assert_no_tag :tag => "a", :attributes => { :title => "Edit" } 
		assert_no_tag :tag => "a", :attributes => { :title => "Delete" } 
		assert_no_tag :tag => "a", :content => "Add Time Entries"
  end

	test "show view with 'edit contracts' permission" do
		Role.find(4).add_permission! :view_contract_details
		Role.find(4).add_permission! :edit_contracts
    get :show, :project_id => @project.id, :id => @contract.id
		assert_tag :tag => "a", :attributes => { :title => "Edit" }
		assert_tag :tag => "a", :content => "Add Time Entries"
	end	

	test "show view with 'delete contracts' permission" do
		Role.find(4).add_permission! :view_contract_details
		Role.find(4).add_permission! :delete_contracts
    get :show, :project_id => @project.id, :id => @contract.id
		assert_tag :tag => "a", :attributes => { :title => "Delete" }
	end	

	test "show view with 'view hourly rates' permission" do
		Role.find(4).add_permission! :view_contract_details
		Role.find(4).add_permission! :view_hourly_rate
    get :show, :project_id => @project.id, :id => @contract.id
		assert_tag :tag => "th", :content => "Hourly Rate"
	end	

  test "edit view" do 
		Role.find(4).add_permission! :edit_contracts
    get :edit, :project_id => @project.id, :id => @contract.id
    assert_select "h2", "Editing Contract - #{@contract.title}"
    assert_template :partial => "_form"
  end

	test "add time entries view with edit contract permission" do
		Role.find(4).add_permission! :edit_contracts
		get :add_time_entries, :project_id => @project.id, :id => @contract.id
		assert_response :success
		@project.time_entries.each { |entry| assert_tag :tag => "td", :content => "#{entry.hours}" }
		@project.children.each do |subproject|
			subproject.time_entries.each { |entry| assert_tag :tag => "td", :content => "#{entry.hours}" }	
		end
	end
end
