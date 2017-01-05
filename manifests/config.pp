# Class exim::config
#
# this class is called via init.pp
#
class exim::config (
  $add_environment,
  $adminserver,
  $aliases_target,
  $cfgdir,
  $cfgfile,
  $keep_environment,
  $maildomain,
  $primary_hostname,
  $trusted_users,
  $relay_from_hosts,
  $relay_from_internal_network,
  $rewrite_targets,
  $role,
  $smarthost_auth,
  $smarthost_connection_max_messages,
  $smarthost_interface,
  $smarthost_password,
  $smarthost_port,
  $smarthost_user,
  $template_vars,
  $tls_advertise_hosts,
  $tls_certificate,
  $tls_privatekey,
) {
  case $role {
    'admin': {

      if $::ipaddress_internal and $relay_from_internal_network {
        $parts = split($::ipaddress_internal, '[.]')
        $internal_network = join([values_at($parts, 0), values_at($parts, 1), values_at($parts, 2), '0/24'], '.')
      } else {
        $internal_network = undef
      }

      file { $cfgfile:
        mode    => '0640',
        content => template('exim/exim_admin.conf.erb'),
      }
    }
    'slave': {
      if (! $adminserver) {
          fail("adminserver not set to IP/DNS of adminserver: '${adminserver}'")
        }

      if ($smarthost_auth)  {
        if (! $smarthost_interface) {
            fail("smarthost_interface not set to IP/DNS of smarthost_interface: '${smarthost_interface}'")
        }
        if (! $smarthost_user) {
            fail('smarthost_user not set')
        }
        if (! $smarthost_password) {
            fail('smarthost_password not set')
        }
      }

      file { $cfgfile:
        mode    => '0640',
        content => template('exim/exim_slave.conf.erb'),
      }
    }
    'management_platform': {
      if (! $adminserver) {
          fail("adminserver not set to IP/DNS of adminserver: '${adminserver}'")
        }

      file { $cfgfile:
        mode    => '0440',
        content => template('exim/exim_management_platform.conf.erb'),
      }
    }
    default: {
      fail("Unknown role: ${role}")
    }
  }

  if $::osfamily == 'Debian' {
    file {
      "${cfgdir}/exim4.conf.template":
        ensure => absent;
      "${cfgdir}/passwd.client":
        ensure => absent;
      "${cfgdir}/update-exim4.conf.conf":
        ensure  => file,
        content => '',
    }

    file { '/etc/mailname':
      ensure  => absent,
    }
  }
}
