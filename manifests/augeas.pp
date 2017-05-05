# Installs Augeas
class puppet::augeas {
  include infra::apt::tryphon

  package { 'libaugeas-ruby': }

  file { ['/usr/local/share/augeas', '/usr/local/share/augeas/lenses']:
    ensure  => directory,
    require => Package[libaugeas-ruby]
  }

  file { '/usr/share/augeas/lenses/contrib': # used by CampToCamp modules
    ensure  => link,
    target  => '/usr/local/share/augeas/lenses',
    require => File['/usr/local/share/augeas/lenses']
  }
}
