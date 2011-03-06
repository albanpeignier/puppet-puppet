class puppet::master inherits puppet::client {
    package { puppetmaster: 
      ensure => latest,
      require => Apt::Preferences["puppetmaster"]
    }

    apt::preferences { puppetmaster:
      package => puppetmaster, 
      pin => "release a=lenny-backports",
      priority => 999,
      require => Apt::Sources_List["lenny-backports"]
    }

    service { puppetmaster:
      ensure => running,
      enable => true,
      pattern => "/usr/bin/puppet master",
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

    # used to create passwords
    package { pwgen: }

    file { ["/var/lib/puppet/conf", "/var/lib/puppet/conf/releases", "/var/lib/puppet/conf/shared"]:
      ensure => directory,
      mode => 2775,
      group => src,
      require => File["/var/lib/puppet"]
    }

    file { "/var/lib/puppet/conf/current":
      mode => 775,
      group => src
    }
}

class puppet::master::storeconfigs {

  package { [rails, libsqlite3-ruby]: ensure => installed }

}
