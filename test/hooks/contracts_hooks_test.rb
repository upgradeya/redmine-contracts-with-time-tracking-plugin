require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/contracts/hooks', __FILE__)

class ContractsHookListenerTest < ActionController::TestCase
  include Redmine::Hook::Helper
  fixtures :contracts

  def setup
    hook_listener = ContractsHookListener.new
    @contract = contracts(:contract_one)
    @contract.save
  end

  test "hook for timelog should decrease amount_remaining" do
    original_amount_remaining = @contract.amount_remaining
    hours = 10
    params = { :time_entry => { :custom_field_values => { "1" => "1" }, :hours => hours }, 
                :contract => { :contract_id => @contract.id  }
             }
    hook_listener.controller_time_log_edit_before_save(params)
    assert_equal @contract.amount_remaining, (original_amount_remaining - (@contract.hourly_rate * hours))
  end

  #def controller_timelog_edit_before_save(context={})
   # if context[:params][:time_entry][:custom_field_values]["1"] == "1"
    #  if context[:params][:contract][:contract_id] && context[:time_entry][:hours]
     #   contract = Contract.find(context[:params][:contract][:contract_id])
      #  contract.amount_remaining -= (contract.hourly_rate * context[:time_entry][:hours])
       # contract.save
      #end
    #end
  #end
end
