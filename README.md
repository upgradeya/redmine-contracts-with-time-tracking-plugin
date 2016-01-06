A Redmine plugin for managing the time/money being spent on client contracts.

This plugin allows you to: 

- Create and store client contracts
- Visualize how much time/money has been spent on a particular contract
- Associate time entries with specific contracts

### Special thanks to [UpgradeYa](http://www.upgradeya.com) for funding this project. 

Installation
------------ 

1. go to your redmine plugins directory (eg cd /opt/redmine/plugins)
2. run git clone for the project (eg git clone https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin.git plugins/contracts or git clone https://github.com/Sam-R/redmine-contracts-with-time-tracking-plugin.git )
3. Rename the checked out project to contracts ( mv redmine-contracts-with-time-tracking-plugin contracts )
4. go to your Redmine root directory ( eg cd /opt/redmine )
5. run 'rake redmine:plugins:migrate RAILS_ENV=production'
6. Restart your webserver ( eg service apache2 restart )


Screenshots
-----------

### View all contracts for a project:
![view contracts for project](https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin/raw/master/docs/screenshots/multiple_contracts.png)

### View contract details:
![view contract details](https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin/raw/master/docs/screenshots/single_contract.png)

### Create and edit contracts:
![create and edit contracts](https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin/raw/master/docs/screenshots/edit_contract.png)

### Set permisisons:
![manage permissions](https://github.com/bsyzek/redmine-contracts-with-time-tracking-plugin/raw/master/docs/screenshots/permissions.png)

Changelog
---------

Contracts 1.3.1, 2015-12-27
---------------------------
- Implemented new feature to lock contracts. This can be used to prevent old contracts and their time entries from accidentally being edited.
- Locked contracts are hidden from new time entry dropdowns
- Implementing caching on locked contracts to decrease load time on the contract pages.

Contracts 1.2.0, 2015-12-14
---------------------------
- On contract form the fields are now inline and date fields use calendar widget. Required fields are now marked. Any validations will re-populate the screen with previous data.
- Adding a time entry selects last created contract. Used to use start and end date. For sub-projects it selects the last created contract within the sub-project if a contract exists. Also fixed for expenses. Currently there is no way to add expense in sub-project to the parent contract if there are no sub-project contracts.
- New Agreement Pending - (basically just not marking that field as required) Agreed on date shows agreement pending on contract list and detail page. Date range is not shown when agreement is pending.
- If they have auto-contract creation enabled, a time entry that exceeds the remaining contract will auto-create a new contract and submit a time entry to the new contract with the remaining time.
- Discussion on the title. Fixed title format. Auto-increments based on all the projects IDs. Need to add a per project identifier so the auto-increment is project based and not entire redmine based.