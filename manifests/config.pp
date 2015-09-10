# Class exim::config
#
# this class is called via init.pp
#
class exim::config () {
  case $exim::role {
    'admin': {

      if $::ipaddress_internal and $exim::relay_from_internal_network {
        $parts = split($::ipaddress_internal, '[.]')
        $internal_network = join([values_at($parts, 0), values_at($parts, 1), values_at($parts, 2), '0/24'], '.')
      } else {
        $internal_network = ''
      }

      file { $exim::cfgfile:
        mode    => '0640',
        content => template('exim/exim_admin.conf.erb'),
      }
    }
    'slave': {
      if (! $exim::adminserver) {
          fail("adminserver not set to IP/DNS of adminserver: '$exim::adminserver'")
        }

      if ($smarthost_auth)  {
        if (! $exim::smarthost_interface) {
            fail("smarthost_interface not set to IP/DNS of smarthost_interface: '$exim::smarthost_interface'")
        }
        if (! $exim::smarthost_user) {
            fail('smarthost_user not set')
        }
        if (! $exim::smarthost_password) {
            fail('smarthost_password not set')
        }
      }

      file { $exim::cfgfile:
        mode    => '0640',
        content => template('exim/exim_slave.conf.erb'),
      }
    }
    'management_platform': {
      if (! $exim::adminserver) {
          fail("adminserver not set to IP/DNS of adminserver: '$exim::adminserver'")
        }

      file { $exim::cfgfile:
        mode    => '0440',
        content => template('exim/exim_management_platform.conf.erb'),
      }
    }
    default: {
      fail("Unknown role: $exim::role")
    }
  }

  if $::osfamily == 'Debian' {
    file {
      "$exim::cfgdir/exim4.conf.template":
        ensure => absent;
      "$exim::cfgdir/passwd.client":
        ensure => absent;
      "$exim::cfgdir/update-exim4.conf.conf":
        ensure  => file,
        content => '',
    }

    file { '/etc/mailname':
      ensure  => absent,
    }
  }
}
