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

class TimeEntryTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :users, :time_entries,
           :members, :roles, :member_roles,
           :trackers, :issue_statuses,
           :journals, :journal_details,
           :issue_categories, :enumerations,
           :groups_users,
           :enabled_modules,
           :workflows,
           :contracts

  test "should have a contract attribute" do
    time_entry = TimeEntry.new
    assert_respond_to time_entry, "contract"
  end

  test "should not save if exceeds remaining contract time" do
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @project = projects(:projects_001)
    @user = users(:users_004)
    @contract = contracts(:contract_one)
    new_time_entry = TimeEntry.new
    new_time_entry.project_id = @project.id
    new_time_entry.user_id = @user.id
    new_time_entry.hours = @contract.hours_remaining + 5
    new_time_entry.contract_id = @contract.id
    assert !new_time_entry.save, "Saved the entry exceeding the remaining contract time"
    assert_match /is invalid. The contract #{@contract.title} only has #{"%.2f" % @contract.hours_remaining} hours remaining. Ask your administrator to enable auto contract creation in contract settings./,
      new_time_entry.errors.messages[:hours].to_s
  end
end
