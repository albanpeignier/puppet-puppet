class puppet::common {
  include apt::backports
  if $debian::wheezy {
    include puppet::ruby
  }

  if $debian::lenny {
    apt::preferences { puppet-common:
      package => puppet-common,
      pin => "release a=lenny-backports",
      priority => 999,
      require => Apt::Sources_List["lenny-backports"],
      before => Package[puppet]
    }
  }

  if $debian::squeeze {
    apt::preferences { puppet-common:
      package => puppet-common,
      pin => "release a=squeeze-backports",
      priority => 999,
      require => Apt::Sources_List["squeeze-backports"],
      before => Package[puppet]
    }
  }
}

class puppet::ruby {
  # Requires gem command to be ~> 1.9.3

  file { '/usr/bin/gem':
    ensure => link,
    target => '/usr/bin/gem1.9.1'
  }

  # Dummy package (from bearstech ?) via forced links for ruby, gem, etc
  package { 'ruby': ensure => purged }
}
