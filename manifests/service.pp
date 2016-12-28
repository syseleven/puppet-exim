# Class: exim::service
#
class exim::service () {

  service { $exim::service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    tag        => 'openssl-restart-required',
  }

}
