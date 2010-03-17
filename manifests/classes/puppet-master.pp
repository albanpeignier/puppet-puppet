class puppet::master inherits puppet::client {
    package { puppetmaster: ensure => present }

    service { puppetmaster:
        ensure => running,
        enable => true,
        require => [ Package[puppet], Package[puppetmaster] ]
    }

    Service[puppet]{
        require +> Service[puppetmaster],
    }

    File["/etc/puppet/puppet.conf"]{
        source => [ "puppet://$server/files/puppet/master/puppet.conf",
                    "puppet://$server/puppet/master/puppet.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
    }

    file { "/var/lib/puppet":
      ensure => directory,
      group => puppet,
      mode => 775
    }

    file { "/var/lib/puppet/reports": 
      owner => puppet,
      ensure => directory
    }

    file { "/etc/puppet/fileserver.conf":
        source => [ "puppet://$server/files/puppet/master/fileserver.conf",
                    "puppet://$server/puppet/master/fileserver.conf" ],
        notify => [Service[puppet],Service[puppetmaster] ],
        owner => root, group => 0, mode => 644;
    }

    if $puppetmaster_storeconfigs {
        include puppet::master::storeconfigs
    }

    # restart the master from time to time to avoid memory problems
    file{'/etc/cron.d/puppetmaster.cron':
        source => "puppet://$server/puppet/puppetmaster.cron",
        owner => root, group => 0, mode => 0644;
    }

    # namespaceauth.conf breaks puppetmaster
    File["/etc/puppet/namespaceauth.conf"] { ensure => absent }

}

class puppet::master::storeconfigs {

  package { [rails, libsqlite3-ruby]: ensure => installed }

}
