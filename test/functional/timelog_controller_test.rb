# -*- coding: utf-8 -*-
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
    @contract   = contracts(:contract_three)
    @contract2  = contracts(:contract_two)
  end

  test "should create time entry if hours is under amount remaining" do
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    @request.session[:user_id] = 3
    post :create, :project_id => 1,
                  :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2015-03-14',
                                :issue_id => '1',
                                :hours => 1,
                                :contract_id => @contract.id}
    assert_response 302
    assert_equal "Successful creation.", flash[:notice]
  end

  test "should not create time entry if hours is over amount remaining" do
    Setting.plugin_contracts = {
      'automatic_contract_creation' => false
    }
    entry_hours = @contract.hours_remaining + 1
    @request.session[:user_id] = 3
    post :create, :project_id => 1,
                  :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2015-03-14',
                                :issue_id => '1',
                                :hours => entry_hours,
                                :contract_id => @contract.id}
    assert_response 200
    assert_select("div#errorExplanation", /Hours is invalid. The contract/)
  end

  test "a new contract is created automatically" do
    Setting.plugin_contracts = {
      'automatic_contract_creation' => true
    }
    @contract.project_contract_id = 10;
    @contract.save
    @request.session[:user_id] = 3
    entry_hours = @contract.hours_remaining + 1
    post :create, :project_id => 1,
                  :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2015-03-14',
                                :issue_id => '1',
                                :hours => entry_hours,
                                :contract_id => @contract.id}
    assert_response 302
    assert_equal "Successful creation.", flash[:notice]
    assert_match /Your time entry has been split into two entries/, flash[:contract]
  end
end
