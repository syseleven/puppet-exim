# Class exim::base
#
# WARNING! Deprecated: Use exim instead
#
# Parameters:
#   none
#
class exim::base {

  package { 'exim':
    ensure => installed
  }
  service { 'exim':
    ensure     => running,
    enable     => true,
    start      => '/etc/init.d/exim restart',
    hasstatus  => true,
    hasrestart => true,
  }

}
