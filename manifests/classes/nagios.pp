class puppet::nagios {
  file { '/etc/nagios3/services/puppet.cfg':
    source => 'puppet:///modules/puppet/nagios/puppet.cfg',
    require => Package['nagios']
  }

  file { '/etc/sudoers.d/check_puppetmaster':
    content => "nagios  ALL=(puppet) NOPASSWD: /usr/local/lib/nagios/plugins/check_puppetmaster\n",
    require => Package['sudo']
  }

  nagios::plugin { 'check_puppetmaster':
    source => 'puppet:///modules/puppet/nagios/check_puppetmaster.sh'
  }
}
