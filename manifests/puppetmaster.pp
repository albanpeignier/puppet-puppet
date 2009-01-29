# manifests/puppetmaster.pp

import "storeconfigs.pp"

class puppet::puppetmaster inherits puppet {
    case $operatingsystem {
        debian: { include puppet::puppetmaster::debian }
        centos: { include puppet::puppetmaster::centos }
        default: {
            case $kernel {
                linux: { include puppet::puppetmaster::linux }
            }
        }
    }
    include puppet::puppetmaster::base
}

class puppet::puppetmaster::base inherits puppet::base {

    File[puppet_config]{
        source => [ "puppet://$server/files/puppet/master/puppet.conf",
                    "puppet://$server/puppet/master/puppet.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
    }

    $real_puppet_fileserverconfig = $puppet_fileserverconfig ? {
        '' => "/etc/puppet/fileserver.conf",
        default => $puppet_fileserverconfig,
    }

    file { "$real_puppet_fileserverconfig":
        source => [ "puppet://$server/files/puppet/master/${fqdn}/fileserver.conf",
                    "puppet://$server/files/puppet/master/fileserver.conf",
                    "puppet://$server/puppet/master/fileserver.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
        owner => root, group => 0, mode => 600;
    }

    if $puppetmaster_storeconfigs {
        include puppet::puppetmaster::storeconfigs
    }

    # restart the master from time to time to avoid memory problems
    file{'/etc/cron.d/puppetmaster.cron':
        source => [ "puppet://$server/puppet/cron.d/puppetmaster.${operatingsystem}",
                    "puppet://$server/puppet/cron.d/puppetmaster" ],
        owner => root, group => 0, mode => 0644;
    }

    # namespaceauth.conf breaks puppetmaster
    File['puppet_namespaceauth_config'] { ensure => absent }

}


define puppet::puppetmaster::hasdb(
    $dbtype = 'mysql',
    $dbname = 'puppet',
    $dbhost = 'localhost',
    # this is needed due to the collection of the databases
    $dbhostfqdn = "${fqdn}",
    $dbuser = 'puppet',
    $dbpwd = $puppet_storeconfig_password,
    $dbconnectinghost = 'locahost'
){

    case $puppet_storeconfig_password {
        '': { fail("No \$puppet_storeconfig_password is set, please set it in your manifests or site.pp to add a password") }
    }

    case $dbtype {
      'mysql': {  
        include puppet::puppetmaster::mysql
        puppet::puppetmaster::hasdb::mysql{$name: dbname => $dbname, dbhost => $dbhost, dbuser => $dbuser, dbpwd => $dbpwd, } 
      }
    }
}
