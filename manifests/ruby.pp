class puppet::ruby {
  # Requires gem command to be ~> 1.9.3

  file { '/usr/bin/gem':
    ensure => link,
    target => '/usr/bin/gem1.9.1'
  }

  # Dummy package (from bearstech ?) via forced links for ruby, gem, etc
  package { 'ruby': ensure => purged }
}
