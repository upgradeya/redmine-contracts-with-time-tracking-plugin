require File.expand_path('../../test_helper', __FILE__)

class ContractsControllerTest < ActionController::TestCase
  fixtures :contracts, :projects

  def setup 
    @contract = contracts(:contract_one)
    @project = projects(:projects_001)
    @contract.project_id = @project.id
  end

  test "index view" do 
    get :index, :project_id => @project.id
    assert_response :success
    
    assert_select 'h2', "Contracts"
    assert_tag :tag => "a", :content => "New Contract"
    assert_tag :tag => "h3", :content => "Total Purchased for All Contracts" 
    assert_tag :tag => "h3", :content => "Total Remaining for All Contracts" 
    
    assert_tag :tag => "table", :attributes => { :class => "contracts_table" }
    assert_tag :tag => "td", :content => "Name"
    assert_tag :tag => "td", :content => "Agreed On"
    assert_tag :tag => "td", :content => "Date Range"
    assert_tag :tag => "td", :content => "Amount Purchased"
    assert_tag :tag => "td", :content => "Amount Remaining"
    assert_tag :tag => "td", :content => "Hours Worked"
    assert_tag :tag => "td", :content => "~Hours Remaining"
    assert_tag :tag => "td", :content => "Contract"
    assert_tag :tag => "td", :content => "Invoice"

    assert_tag :tag => "a", :content => "Sample Contract"
  end

  test "new view" do
    @request.session[:user_id] = 1
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

  test "show view" do
    @request.session[:user_id] = 1
    get :show, :project_id => @project.id, :id => @contract.id
    assert_select "h2", "#{@contract.title} (edit)"
    assert_tag :tag => "a", :content => "edit"
    assert_tag :tag => "p", :content => "Title:"
    assert_tag :tag => "p", :content => "Description:"
    assert_tag :tag => "p", :content => "Agreement Date:"
    assert_tag :tag => "p", :content => "Start Date:"
    assert_tag :tag => "p", :content => "End Date:"
    assert_tag :tag => "p", :content => "Hourly Rate:"
    assert_tag :tag => "p", :content => "Project:"
    assert_tag :tag => "p", :content => "Contract:"

    assert_tag :tag => "h3", :content => "Time Entries"
    assert_tag :tag => "table", :attributes => { :class => "time_entries_for_contract" }

  end

  test "edit view" do 
    @request.session[:user_id] = 1
    get :edit, :project_id => @project.id, :id => @contract.id
    assert_select "h2", "Editing Contract - #{@contract.title}"
    assert_template :partial => "_form"
  end
end
