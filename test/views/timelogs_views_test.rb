require File.expand_path('../../test_helper', __FILE__)
require 'timelog_controller'

# Re-raise errors caught by the controller.
class TimelogController; def rescue_action(e) raise e end; end

class TimelogControllerTest < ActionController::TestCase
  fixtures :projects, :enabled_modules, :roles, :members,
    :member_roles, :issues, :time_entries, :users,
    :trackers, :enumerations, :issue_statuses,
    :custom_fields, :custom_values

  include Redmine::I18n

  def setup
    @controller = TimelogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_new
    @request.session[:user_id] = 3
    get :new, :project_id => 1
    assert_response :success
    assert_tag :tag => "select", :attributes => { :id => "contract_contract_id" }
  end 
end
