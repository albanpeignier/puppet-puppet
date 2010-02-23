class puppet::client {

  package {"facter":
    ensure  => $facter_version ? {
      ""      => latest,
      default => $facter_version,
    },
    require => Package["lsb-release"],
    tag     => "install-puppet",
  }

  package {"puppet":
    ensure  => $puppet_client_version ? {
      ""      => latest,
      default => $puppet_client_version,
    },
    require => Package["facter"],
    tag     => "install-puppet",
  }

  package {"lsb-release":
    name => $operatingsystem ? {
      Debian => "lsb-release",
      Ubuntu => "lsb-release",
      Redhat => "redhat-lsb",
      fedora => "redhat-lsb",
    },
    ensure => present,
  }

  service { "puppet":
    ensure    => stopped,
    enable    => false,
    hasstatus => false,
    tag       => "install-puppet",
    pattern   => "ruby /usr/sbin/puppetd -w",
    # make sure the puppet cron is installed before the service is stopped
    require => [ Cron[puppetd], File["/etc/puppet/puppet.conf"] ]
  }

  user { "puppet":
    ensure => present,
    require => Package["puppet"],
  }

  file {"/etc/puppet/puppetd.conf": ensure => absent }

  file { "/etc/puppet/puppet.conf":
    source => [ "puppet://$server/files/puppet/client/${fqdn}/puppet.conf",
      "puppet://$server/files/puppet/client/puppet.conf",
      "puppet://$server/puppet/client/puppet.conf" ],
    owner => root, group => 0, mode => 644;
  }

  file { "/etc/puppet/namespaceauth.conf":
    source => [ "puppet://$server/files/puppet/client/${fqdn}/namespaceauth.conf",
                "puppet://$server/files/puppet/client/namespaceauth.conf.$operatingsystem",
                "puppet://$server/files/puppet/client/namespaceauth.conf",
                "puppet://$server/puppet/client/namespaceauth.conf.$operatingsystem",
                "puppet://$server/puppet/client/namespaceauth.conf" ],
    owner => root, group => 0, mode => 600;
  }

  file {"/var/run/puppet/":
    ensure => directory,
    owner  => "puppet",
    group  => "puppet",
  }

  # Don't start puppet with network interface
  file { ["/etc/network/if-up.d/puppetd", "/etc/network/if-down.d/puppetd"]:
    ensure => absent
  }

  $puppet_server = "puppet"

  file{"/usr/local/sbin/launch-puppet":
    ensure => present,
    mode => 755,
    content => template("puppet/launch-puppet.erb"),
    tag     => "install-puppet",
  }

  # Run puppetd with cron instead of having it hanging around and eating so
  # much memory.
  cron { "puppetd":
    ensure  => present,
    command => "/usr/local/sbin/launch-puppet",
    user    => 'root',
    environment => "MAILTO=root",
    minute  => 15,
    require => File["/usr/local/sbin/launch-puppet"],
    tag     => "install-puppet",
  }         

  file { "/etc/cron.d/puppetd":
    ensure => absent
  }

  file { "/etc/default/puppet":
    source => "puppet:///puppet/client/puppet.default",
    require => Package["puppet"]
  }

  file { "/etc/init.d/puppet":
    source => "puppet:///puppet/client/puppet.initd",
    mode => 755,
    require => Package["puppet"]
  }

}

class puppet::augeas {
  include apt::tryphon

  package { libaugeas-ruby: 
    require => Apt::Preferences[libaugeas-ruby]
  }

  apt::preferences { libaugeas-ruby:
    package => libaugeas-ruby, 
    pin => "release a=lenny-backports",
    priority => 999,
    require => Apt::Preferences["libaugeas-ruby1.8"]
  }

  apt::preferences { "libaugeas-ruby1.8":
    package => "libaugeas-ruby1.8", 
    pin => "release a=lenny-backports",
    priority => 999
  }

  apt::preferences { "libaugeas0":
    package => "libaugeas0", 
    pin => "release a=lenny-backports",
    priority => 999
  }
  
  file { ["/usr/local/share/augeas", "/usr/local/share/augeas/lenses"]:
    ensure => directory
  }

  define lens($source) {
    file { "/usr/local/share/augeas/lenses/$name.aug":
      source => $source
    }
  }

}
