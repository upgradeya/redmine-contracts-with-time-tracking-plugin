# Redmine - project management software
# Copyright (C) 2006-2012  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :projects, :contracts, :time_entries, :user_project_rates, :users

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @project        = projects(:projects_001)
    @contract       = contracts(:contract_one)
    @contract.project_id = @project.id
    @contract.save
    @user = @project.users.first
  end

  test "should have many user project rates" do
    assert_respond_to @user, :user_project_rates
  end

  test "should have many user contract rates" do
    assert_respond_to @user, :user_contract_rates
  end

  test "should add a new user project rate" do
    assert_not_nil @user
    if upr = @project.user_project_rate_by_user(@user)
      upr.destroy
    end
    assert_nil @project.user_project_rate_by_user(@user)
    upr = @project.user_project_rates.create!(:user_id => @user.id, :rate => 25.00)
    assert_equal [upr], @project.user_project_rates
    assert_equal @user, upr.user
    assert_equal 25.00, upr.rate
  end

end
