# Class: exim
#
class exim (
  $role,
  $postmaster,
  $package = $exim::params::package,
  $service = $exim::params::service,
  $version = 'installed',
  $useflags = undef,
  $adminserver = undef,
  $warn_limit = '100',
  $crit_limit = '1000',
  $maildomain = '@',
  $primary_hostname = $fqdn,
  $rewrite_targets = [],
  $trusted_users = [],
  $tls_advertise_hosts = '""', # exim wants "" as empty value...
  $tls_certificate = false,
  $tls_privatekey = false,
  $aliases = undef,
  $aliases_target = $exim::params::aliases_target,
  $relay_from_internal_network = true,
  $relay_from_hosts = [],
  $monitoring_smtp_hostname = 'localhost',
  $monitoring_smtp_ip_family = 'inet',
  $cfgdir = $exim::params::cfgdir,
  $cfgfile = $exim::params::cfgfile,
  $logfile = $exim::params::logfile,
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $enable_nagioscheck = true,
  $template_vars = {},
  $smarthost_auth = false,
  $smarthost_user = false,
  $smarthost_password = false,
  $smarthost_interface = false,
  $smarthost_connection_max_messages = 100,
  $smarthost_port = 25,
  $add_environment = $exim::params::add_environment,
  $keep_environment = $exim::params::keep_environment,
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
  class { 'exim::package':
    package  => $package,
    useflags => $useflags,
    version  => $version,
  }->
  class { 'exim::config':
    add_environment                   => $add_environment,
    adminserver                       => $adminserver,
    aliases_target                    => $aliases_target,
    cfgdir                            => $cfgdir,
    cfgfile                           => $cfgfile,
    keep_environment                  => $keep_environment,
    maildomain                        => $maildomain,
    primary_hostname                  => $primary_hostname,
    relay_from_hosts                  => $relay_from_hosts,
    relay_from_internal_network       => $relay_from_internal_network,
    rewrite_targets                   => $rewrite_targets,
    role                              => $role,
    smarthost_auth                    => $smarthost_auth,
    smarthost_connection_max_messages => $smarthost_connection_max_messages,
    smarthost_interface               => $smarthost_interface,
    smarthost_password                => $smarthost_password,
    smarthost_port                    => $smarthost_port,
    smarthost_user                    => $smarthost_user,
    template_vars                     => $template_vars,
    tls_advertise_hosts               => $tls_advertise_hosts,
    tls_certificate                   => $tls_certificate,
    tls_privatekey                    => $tls_privatekey,
    trusted_users                     => $real_trusted_users,
  }->
  class { 'exim::service':
    service   => $service,
    subscribe => Class['exim::package', 'exim::config'],
  }
  if $enable_nagioscheck {
    class { 'exim::nagioscheck':
      warn_limit     => $warn_limit,
      crit_limit     => $crit_limit,
      logfile        => $logfile,
      smtp_hostname  => $monitoring_smtp_hostname,
      smtp_ip_family => $monitoring_smtp_ip_family,
      monit_check    => $monit_check,
      monit_tests    => $monit_tests,
      service        => $service,
      require        => Class['exim::service'],
    }
  }
  class { 'exim::alias':
    aliases        => $aliases,
    aliases_target => $aliases_target,
    postmaster     => $postmaster,
    require        => Class['exim::service'],
  }->
  anchor { 'exim::end': }

}
