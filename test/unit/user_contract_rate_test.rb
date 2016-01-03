require File.expand_path('../../test_helper', __FILE__)

class UserContractRateTest < ActiveSupport::TestCase
  fixtures :projects, :contracts, :time_entries, :user_contract_rates

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @project = projects(:projects_001)
    @contract = contracts(:contract_one)
    @user = @project.users.first
    @user_contract_rate = UserContractRate.create!(:contract => @contract, :user => @user)
  end

  test "should belong to a user" do
    assert_respond_to @user_contract_rate, :user
    assert_equal @user, @user_contract_rate.user
  end

  test "should belong to a contract" do
    assert_respond_to @user_contract_rate, :contract
    assert_equal @contract, @user_contract_rate.contract
  end
end
