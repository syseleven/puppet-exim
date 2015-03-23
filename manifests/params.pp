# Class: exim::params
#
class exim::params () {

  case $::operatingsystem {
    'gentoo': {
      $package = 'mail-mta/exim'
      $service = 'exim'
      $aliases_target = '/etc/mail/aliases'
      $cfgdir = '/etc/exim'
      $cfgfile = "$cfgdir/exim.conf"
      $logfile = '/var/log/exim/exim_main.log'
    }
    'ubuntu', 'debian': {
      $package = 'exim4'
      $service = 'exim4'
      $aliases_target = '/etc/aliases'
      $cfgdir = '/etc/exim4'
      $cfgfile = "$cfgdir/exim4.conf"
      $logfile = '/var/log/exim4/mainlog'
    }
    'centos': {
      $package = 'exim'
      $service = 'exim'
      $aliases_target = '/etc/aliases'
      $cfgdir = '/etc/exim'
      $cfgfile = "$cfgdir/exim.conf"
      $logfile = '/var/log/exim/main.log'
    }
    default: {
      fail("Unknown OS: $::operatingsystem")
    }
  }

}
