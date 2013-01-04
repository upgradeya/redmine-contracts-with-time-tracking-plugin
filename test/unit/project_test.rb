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
  fixtures :projects, :contracts, :time_entries

  def setup
    @project 				= projects(:projects_001)
		@subproject 		= projects(:projects_003)
		@sub_subproject =	projects(:projects_004)
    @contract 			= contracts(:contract_one)
    @contract2 			= contracts(:contract_two)
		@time_entry1		= time_entries(:time_entries_001)
		@time_entry2		= time_entries(:time_entries_004)
		@time_entry3 		= time_entries(:time_entries_005)	
    @contract.project_id = @project.id
    @contract2.project_id = @project.id
    @contract.save
    @contract2.save
		@sub_subproject.parent_id = @subproject.id
		@sub_subproject.save
		@project.time_entries.clear
		@project.time_entries.append(@time_entry1)
		@project.save
		@time_entry3.project_id = @sub_subproject.id
		@time_entry3.save
  end

  test "should have many contracts" do
    assert_respond_to @project, "contracts"
  end

  test "should calculate amount purchased across all contracts" do
    assert_equal @project.total_amount_purchased, Contract.all.sum { |contract| contract.purchase_amount }
  end

  test "should calculate approximate hours purchased across all contracts" do
    assert_equal @project.total_hours_purchased, Contract.all.sum { |contract| contract.hours_purchased }
  end

  test "should calculate amount remaining across all contracts" do
    assert_equal @project.total_amount_remaining, Contract.all.sum { |contract| contract.amount_remaining }
  end

  test "should calculate hours remaining across all contracts" do
    assert_equal @project.total_hours_remaining, Contract.all.sum { |contract| contract.hours_remaining }
  end

	test "should get contracts for all ancestor projects" do
		@contract2.project_id = @subproject.id
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
end
