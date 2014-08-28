A Redmine plugin for managing the time/money being spent on client contracts.

This plugin allows you to: 

- Create and store client contracts
- Visualize how much time/money has been spent on a particular contract
- Associate time entries with specific contracts

### Special thanks to [UpgradeYa](http://www.upgradeya.com) for funding version 1.0 of this project. 

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

