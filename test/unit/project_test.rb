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

class ProjectTest < ActiveSupport::TestCase
  fixtures  :projects, :contracts, :time_entries, :user_project_rates, 
            :user_contract_rates, :users, :members, :enabled_modules

  def setup
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @project        = projects(:projects_001)
    @parent_project     = projects(:projects_003)
    @sub_subproject = projects(:projects_004)
    @contract       = contracts(:contract_one)
    @contract2      = contracts(:contract_two)
    @time_entry1    = time_entries(:time_entries_001)
    @time_entry2    = time_entries(:time_entries_004)
    @time_entry3    = time_entries(:time_entries_005)
    @contract.project_id = @project.id
    @contract2.project_id = @project.id
    @contract.save
    @contract2.save
    @sub_subproject.parent_id = @parent_project.id
    @sub_subproject.save
    @project.time_entries.clear
    @project.time_entries.append(@time_entry1)
    @project.save
    @time_entry3.project_id = @sub_subproject.id
    @time_entry3.save
    @user = @project.users.first
  end

  test "should have many contracts" do
    assert_respond_to @project, "contracts"
  end

  test "should calculate amount purchased across all contracts" do
    assert_equal @project.total_amount_purchased, @project.contracts.map(&:purchase_amount).inject(0, &:+)
  end

  test "should calculate approximate hours purchased across all contracts" do
    assert_equal @project.total_hours_purchased, @project.contracts.map(&:hours_purchased).inject(0, &:+)
  end

  test "should calculate amount remaining across all contracts" do
    assert_equal @project.total_amount_remaining, @project.contracts.map(&:amount_remaining).inject(0, &:+)
  end

  test "should calculate hours remaining across all contracts" do
    assert_equal @project.total_hours_remaining, @project.contracts.map(&:hours_remaining).inject(0, &:+)
  end

  test "should get contracts for all ancestor projects" do
    @contract2.project_id = @parent_project.id
    @contract2.save
    assert_equal 3, @sub_subproject.contracts_for_all_ancestor_projects.count
  end

  test "should get all time entries for current project and all descendent projects" do
    time_entries = @project.time_entries_for_all_descendant_projects
    assert_equal 3, time_entries.count
    assert time_entries.include?(@time_entry1)
    assert time_entries.include?(@time_entry2)
    assert time_entries.include?(@time_entry3)
  end

  test "should have many user project rates" do
    assert_not_nil @user
    @project.set_user_rate(@user, 25.00)
    assert_operator @project.user_project_rates.size, :>=, 1
  end

  test "should get a user project rate by user" do
    assert_not_nil @user
    upr = @project.set_user_rate(@user, 25.00)
    assert_equal upr, @project.user_project_rate_by_user(@user)
  end

  test "should get a rate for a user" do
    assert_not_nil @user
    @project.set_user_rate(@user, 25.00)
    assert_equal 25.00, @project.rate_for_user(@user)
  end

  test "should set a user rate" do
    assert_not_nil @user
    # check the value is not already set
    assert_not_equal 37.25, @project.rate_for_user(@user)
    @project.set_user_rate(@user, 37.25)
    assert_equal 37.25, @project.rate_for_user(@user)
  end

end
