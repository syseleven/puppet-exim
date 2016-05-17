# Class: exim::params
#
class exim::params () {

  case $::operatingsystem {
    'gentoo': {
      $package = 'mail-mta/exim'
      $service = 'exim'
      $aliases_target = '/etc/mail/aliases'
      $cfgdir = '/etc/exim'
      $cfgfile = "${cfgdir}/exim.conf"
      $logfile = '/var/log/exim/exim_main.log'
      $trusted_users_apache = ['apache']
      $trusted_users_nginx = ['nginx']
      $pid = undef
      $add_environment = false
      $keep_environment = false
    }
    'ubuntu', 'debian': {
      $package = 'exim4'
      $service = 'exim4'
      $aliases_target = '/etc/aliases'
      $cfgdir = '/etc/exim4'
      $cfgfile = "${cfgdir}/exim4.conf"
      $logfile = '/var/log/exim4/mainlog'
      $trusted_users_apache = ['www-data']
      $trusted_users_nginx = ['www-data']
      $pid = '/var/run/exim4/exim.pid'
      $add_environment = false
      $keep_environment = '' # lint:ignore:empty_string_assignment
    }
    'centos': {
      $package = 'exim'
      $service = 'exim'
      $aliases_target = '/etc/aliases'
      $cfgdir = '/etc/exim'
      $cfgfile = "${cfgdir}/exim.conf"
      $logfile = '/var/log/exim/main.log'
      $trusted_users_apache = ['apache']
      $trusted_users_nginx = ['nginx']
      $pid = undef
      $add_environment = false
      $keep_environment = '' # lint:ignore:empty_string_assignment
    }
    default: {
      fail("Unknown OS: ${::operatingsystem}")
    }
  }

}
