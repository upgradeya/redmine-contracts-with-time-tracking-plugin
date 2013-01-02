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
  fixtures :projects, :contracts

  def setup
    @project 				= projects(:projects_001)
		@subproject 		= projects(:projects_003)
		@sub_subproject =	projects(:projects_004)
    @contract 			= contracts(:contract_one)
    @contract2 			= contracts(:contract_two)
    @contract.project_id = @project.id
    @contract2.project_id = @project.id
    @contract.save
    @contract2.save
		@sub_subproject.parent_id = @subproject.id
		@sub_subproject.save
  end

  test "should have many contracts" do
    assert_respond_to @project, "contracts"
  end

  test "should calculate amount purchased across all contracts" do
    assert_equal @project.total_amount_purchased, (@contract.purchase_amount + @contract2.purchase_amount)
  end

  test "should calculate approximate hours purchased across all contracts" do
    assert_equal @project.total_hours_purchased, (@contract.hours_purchased + @contract2.hours_purchased)
  end

  test "should calculate amount remaining across all contracts" do
    assert_equal @project.total_amount_remaining, (@contract.amount_remaining + @contract2.amount_remaining)
  end

  test "should calculate hours remaining across all contracts" do
    assert_equal @project.total_hours_remaining, (@contract.hours_remaining + @contract2.hours_remaining)
  end

	test "should get contracts for all ancestor projects" do
		@contract2.project_id = @subproject.id
		@contract2.save
		assert_equal 2, @sub_subproject.contracts_for_all_ancestor_projects.count		
	end
end
