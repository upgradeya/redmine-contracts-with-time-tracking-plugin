require_dependency 'contracts/hooks/hooks'
require_dependency 'contracts/patches/time_entry_patch'
require_dependency 'contracts/patches/project_patch'
require_dependency 'contracts/validators/is_after_agreement_date_validator'
require_dependency 'contracts/validators/is_after_start_date_validator'

Redmine::Plugin.register :contracts do
  name 'Contracts plugin'
  author 'Ben Syzek'
  description 'This is a Redmine plugin for creating and managing contracts.'
  version '0.0.1'
  #url 'http://example.com/path/to/plugin'
  #author_url 'http://example.com/about'
 
  menu :application_menu, :contracts, { :controller => :contracts, :action => :all }, :caption => 'Contracts', :if => Proc.new { User.current.logged? } 
  menu :project_menu, :contracts, { :controller => :contracts, :action => :index }, :caption => 'Contracts', :param => :project_id

  project_module :contracts do
    permission :view_all_contracts_for_project,       :contracts => :index
    permission :view_contract_details,                :contracts => :show
    permission :edit_contracts,                       :contracts => [:edit, :add_time_entries, :assoc_time_entries_with_contract]
    permission :create_contracts,                     :contracts => :new
    permission :delete_contracts,                     :contracts => :destroy
    permission :view_hourly_rate,                     :contracts => :view_hourly_rate #view_hourly_rate is a fake action!
  end
end
