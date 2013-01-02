require File.expand_path('../../test_helper', __FILE__)
require 'timelog_controller'

# Re-raise errors caught by the controller.
class TimelogController; def rescue_action(e) raise e end; end

class TimelogControllerTest < ActionController::TestCase
  fixtures :projects, :enabled_modules, :roles, :members,
    :member_roles, :issues, :time_entries, :users,
    :trackers, :enumerations, :issue_statuses,
    :custom_fields, :custom_values, :contracts

  include Redmine::I18n

  def setup
    @controller = TimelogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
		@contract		= contracts(:contract_one)
		@contract2  = contracts(:contract_two)
		@project 		= projects(:projects_001)
		@subproject = projects(:projects_003)
		@super_subproject = projects(:projects_004)
		@super_subproject.parent_id = @subproject.id
		@super_subproject.save
		@contract.project_id = @project.id
		@contract2.project_id = @subproject.id
		@contract.save
		@contract2.save
    @request.session[:user_id] = 3
  end

  def test_get_new
    get :new, :project_id => @project.id
    assert_response :success
  end 

	test "should show project's contracts in dropdown" do
    get :new, :project_id => @project.id
    assert_response :success
    assert_tag :tag => "select", :attributes => { :id => "time_entry_contract_id" }
		assert_tag :tag => "option", :content => "#{@contract.title}" 
	end

	test "should show project's ancestors's contracts in dropdown" do
		get :new, :project_id => @subproject.id
    assert_response :success
		assert_tag :tag => "option", :content => "#{@contract.title}"	
		assert_tag :tag => "option", :content => "#{@contract2.title}"	
	end
end
