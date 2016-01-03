require File.expand_path('../../test_helper', __FILE__)

class UserProjectRateTest < ActiveSupport::TestCase
  fixtures :projects, :contracts, :time_entries, :user_project_rates

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @project = projects(:projects_001)
    @user = @project.users.first
    @user_project_rate = UserProjectRate.create!(:project => @project, :user => @user)
  end

  test "should belong to a user" do
    assert_respond_to @user_project_rate, :user
    assert_equal @user, @user_project_rate.user
  end

  test "should belong to a project" do
    assert_respond_to @user_project_rate, :project
    assert_equal @project, @user_project_rate.project
  end

end
