# manifests/puppetmaster/package.pp

class puppet::puppetmaster::debian inherits puppet::puppetmaster::linux {
    package { puppetmaster: ensure => present }

    Service[puppetmaster]{
        require +> Package[puppetmaster],
    }
}
