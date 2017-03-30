class puppet::master::storeconfigs {

  package { [rails, libsqlite3-ruby]: ensure => installed }

}
