# Class: exim::package
#
# this class is called via init.pp
#
class exim::package (
  $package,
  $useflags,
  $version,
) {

  if $::operatingsystem == 'gentoo' {

    if $useflags {
      gentoo::useflag { $package:
        flags   => $useflags,
        version => $version,
      }
    }

    if $version != 'installed' and $version != 'latest' and $version != 'absent' {

      sys11lib::ensure_key_value { 'exim_package_keyword':
        file      => '/etc/portage/package.keywords',
        delimiter => ' ',
        key       => $package,
        value     => '~amd64',
        before    => Package[$package],
      }

      # mask newer package versions to prevent up- and downgrades in loop

      sys11lib::ensure_key_value { 'exim_package_mask':
        file      => '/etc/portage/package.mask',
        key       => ">${package}",
        delimiter => '-',
        value     => $version,
        before    => Package[$package],
      }
    }
  }

  package { $package:
    ensure => $version,
    alias  => 'exim',
  }

  if $::osfamily == 'Debian' {
    package { 'bsd-mailx':
      ensure  => present,
      require => Package[$package],
    }
  }
}
