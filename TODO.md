# TODO

- [] Replace MariaDB installation with cf-mysql-release
- [] which port does mysql run on? jepsen thinks 3306.
- [] replace mysqld-style start/stop/restart with monit commands
- [] replace grepkill-style restart with 'monit restart'
- [] check for hard-coded paths (e.g. configuration) that's located elsewhere on the stemcell (e.g. /var/vcap/...)
- [] Configure cf-mysql-release in the same way as done in the test
- [] Run the test with a start script
- [] Run on OpenStack instead of bosh-lite
- [] Do we need to run as root?
- [] Bonus: How to add own tests?
