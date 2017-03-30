class puppet::common {

  if $lsbdistcodename != 'jessie' {
    include apt::backports
  }

  if $lsbdistcodename == 'wheezy' {
    include puppet::ruby
  }

  if $lsbdistcodename == 'lenny' {
    apt::preferences { puppet-common:
      package => puppet-common,
      pin => "release a=lenny-backports",
      priority => 999,
      require => Apt::Sources_List["lenny-backports"],
      before => Package[puppet]
    }
  }

  if $lsbdistcodename == 'squeeze' {
    apt::preferences { puppet-common:
      package => puppet-common,
      pin => "release a=squeeze-backports",
      priority => 999,
      require => Apt::Sources_List["squeeze-backports"],
      before => Package[puppet]
    }
  }
}
