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
		@contract 	= contracts(:contract_three)
  end

  test "should warn user if time entry exceeds contract's amount remaining" do 
    @request.session[:user_id] = 3
		hours_over = 7.3 - @contract.hours_remaining 
		hours_left = @contract.hours_remaining
    post :create, :project_id => 1,
                :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2008-03-14',
                                :issue_id => '1',
                                :hours => '7.3',
																:contract_id => @contract.id}
		assert_equal "This time entry exceeded the time remaining for the contract by #{hours_over} hours.\nTo stay within the contract, please edit the time entry to be no more than #{hours_left} hours.", flash[:error]		
  end

  #def test_update
  #  entry = TimeEntry.find(1)
  #  assert_equal 1, entry.issue_id
  #  assert_equal 2, entry.user_id

  #  @request.session[:user_id] = 1
  #  put :update, :id => 1,
  #              :time_entry => {:issue_id => '2',
  #                              :hours => '8'}
  #  assert_redirected_to :action => 'index', :project_id => 'ecookbook'
  #end
end
