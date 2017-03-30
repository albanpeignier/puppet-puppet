class puppet::augeas::lenny {
  apt::preferences { 'libaugeas-ruby':
    package  => libaugeas-ruby,
    pin      => 'release a=lenny-backports',
    priority => 999,
    before   => Package[libaugeas-ruby],
    require  => Apt::Preferences['libaugeas-ruby18']
  }

  apt::preferences { 'libaugeas-ruby18':
    package  => 'libaugeas-ruby1.8',
    pin      => 'release a=lenny-backports',
    priority => 999
  }

  apt::preferences { 'libaugeas0':
    package  => 'libaugeas0',
    pin      => 'release a=lenny-backports',
    priority => 999
  }

  apt::preferences { 'augeas-lenses':
    package  => 'augeas-lenses',
    pin      => 'release a=lenny-backports',
    priority => 999
  }
}
