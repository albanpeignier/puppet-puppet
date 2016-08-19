class puppet::nagios {
  file { '/etc/nagios3/services/puppet.cfg':
    source => 'puppet:///modules/puppet/nagios/puppet.cfg',
    require => Package['nagios']
  }

  sudo::conf { 'check_puppetmaster':
    content => "nagios  ALL=(puppet) NOPASSWD: /usr/local/lib/nagios/plugins/check_puppetmaster"
  }

  nagios::plugin { 'check_puppetmaster':
    source => 'puppet:///modules/puppet/nagios/check_puppetmaster.sh'
  }
}
