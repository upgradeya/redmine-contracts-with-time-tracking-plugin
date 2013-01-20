require_dependency 'contracts/hooks/hooks'
require_dependency 'contracts/patches/time_entry_patch'
require_dependency 'contracts/patches/project_patch'
require_dependency 'contracts/validators/is_after_agreement_date_validator'
require_dependency 'contracts/validators/is_after_start_date_validator'

Redmine::Plugin.register :contracts do
  name 'Redmine Contracts With Time Tracking'
  author 'Ben Syzek'
  description 'A Redmine plugin that allows you to manage contracts and associate time-entries with those contracts.'
  version '1.0.0'
  url 'https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin'
  #author_url 'http://example.com/about'
 
  menu :application_menu, :contracts, { :controller => :contracts, :action => :all }, :caption => :label_contracts, :if => Proc.new { User.current.logged? && User.current.allowed_to?(:view_all_contracts_for_project, nil, :global => true) } 
  menu :project_menu, :contracts, { :controller => :contracts, :action => :index }, :caption => :label_contracts, :param => :project_id

  project_module :contracts do
    permission :view_all_contracts_for_project,       :contracts => :index
    permission :view_contract_details,                :contracts => :show
    permission :edit_contracts,                       :contracts => [:edit, :update, :add_time_entries, :assoc_time_entries_with_contract]
    permission :create_contracts,                     :contracts => [:new, :create]
    permission :delete_contracts,                     :contracts => :destroy
    permission :view_hourly_rate,                     :contracts => :view_hourly_rate #view_hourly_rate is a fake action!
  end
end
