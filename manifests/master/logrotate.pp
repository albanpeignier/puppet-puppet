class puppet::master::logrotate {
    file { "/etc/logrotate.d/puppetmaster":
      source => "puppet://$server/modules/puppet/master/puppetmaster.logrotate",
      mode   => '0644'
    }  
}
