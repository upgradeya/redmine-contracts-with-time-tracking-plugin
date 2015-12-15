module Contracts
	require_dependency 'timelog_controller'

	module TimelogControllerPatch
		def self.included(base)
	  		base.class_eval do
	  			unloadable
	  			after_filter :check_flash_messages, :only => [:create, :update]

	  			def check_flash_messages
	  				if @time_entry.flash_only_one_time_entry
	  					flash[:contract] = l(:text_one_time_entry_saved)
	  				elsif @time_entry.flash_time_entry_success
						flash[:contract] = l(:text_split_time_entry_saved)
				    end
	  			end
	  		end
	 	end
	end
	TimelogController.send(:include, TimelogControllerPatch)
end