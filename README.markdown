# Passive Nagios Plugin Helper

For those people that have many passive nagios checks to run, this is for you.

## Example config:

<pre>>
:services:
  :mysql:
    :description: MYSQL
    :command: check_mysql
  :mysql_slave:
    :description: MYSQL_SLAVE
    :command: check_mysql
    :args: -S
:config:
  :nagios: nagios.example.com
</pre>

## Usage:

<pre>
% ./passive_nagios.rb --help
Usage: passive_nagios [options]
    -c, --config FILE                Config file
    -h, --hostname                   Hostname override
        --verbose                    Be more verbose
% ./passive_nagios.rb -c config.yaml --verbose
[Mon Jul 09 22:01:04 -0700 2012]: running service check mysql
[Mon Jul 09 22:01:04 -0700 2012]: /usr/lib64/nagios/plugins/nsca_wrapper.sh -H test -N nagios.example.com -S MYSQL -C '/usr/lib64/nagios/plugins/check_mysql'
Mon Jul 09 22:01:04 -0700 2012: had a problem while running service check mysql
[Mon Jul 09 22:01:04 -0700 2012]: running service check mysql_slave
[Mon Jul 09 22:01:04 -0700 2012]: /usr/lib64/nagios/plugins/nsca_wrapper.sh -H test -N nagios.example.com -S MYSQL_SLAVE -C '/usr/lib64/nagios/plugins/check_mysql -S'
Mon Jul 09 22:01:04 -0700 2012: had a problem while running service check mysql_slave
[Mon Jul 09 22:01:04 -0700 2012]: Completed run.  2 were successful; 0 failed.
</pre>

---


