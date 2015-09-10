# Class: exim
#
class exim (
  $role,
  $postmaster,
  $package = $exim::params::package,
  $service = $exim::params::service,
  $version = 'latest',
  $useflags = '',
  $adminserver = '',
  $warn_limit = '100',
  $crit_limit = '1000',
  $maildomain = '@',
  $primary_hostname = $fqdn,
  $rewrite_targets = [],
  $trusted_users = [],
  $tls_advertise_hosts = false,
  $tls_certificate = false,
  $tls_privatekey = false,
  $aliases = undef,
  $relay_from_internal_network = true,
  $relay_from_hosts = [],
  $logfile = $exim::params::logfile,
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $enable_nagioscheck = true,
  $template_vars = undef,
  $smarthost_auth = false,
  $smarthost_user = false,
  $smarthost_password = false,
  $smarthost_interface = false,
  $smarthost_connection_max_messages = 100,
  $smarthost_port = 25
) inherits exim::params {

  if defined(Class[apache]) or defined(Class[apache::nagioscheck]) {
    $trusted_users_apache = $exim::params::trusted_users_apache
  } else {
    $trusted_users_apache = []
  }

  if defined(Class[nginx]) or defined(Class[nginx::nagioscheck]) {
    $trusted_users_nginx = $exim::params::trusted_users_nginx
  } else {
    $trusted_users_nginx = []
  }

  # produce list of [$param, 'apache', 'nginx'] and pass to template
  $real_trusted_users = split(inline_template('<%= (@trusted_users + @trusted_users_apache + @trusted_users_nginx).join(",") %>'), ',')

  anchor { 'exim::start': }->
  class { 'exim::package': }->
  class { 'exim::config': }->
  class { 'exim::service':
    subscribe => Class['exim::package', 'exim::config'],
  }
  if $enable_nagioscheck {
    class { 'exim::nagioscheck':
      service     => $service,
      warn_limit  => $warn_limit,
      crit_limit  => $crit_limit,
      logfile     => $logfile,
      monit_check => $monit_check,
      monit_tests => $monit_tests,
      require     => Class['exim::service'],
    }
  }
  class { 'exim::alias':
    require => Class['exim::service'],
  }->
  anchor { 'exim::end': }

}
