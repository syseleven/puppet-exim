# Class: exim::package
#
# this class is called via init.pp
#
class exim::package () {

  if $::operatingsystem == 'gentoo' {

    if $exim::useflags {
      gentoo::useflag { $exim::package:
        flags   => $exim::useflags,
        version => $exim::version,
      }
    }

    if $exim::version != 'installed' and $exim::version != 'latest' and $exim::version != 'absent' {

      sys11lib::ensure_key_value { 'exim_package_keyword':
        file      => '/etc/portage/package.keywords',
        delimiter => ' ',
        key       => $exim::package,
        value     => '~amd64',
        before    => Package[$exim::package],
      }

      # mask newer package versions to prevent up- and downgrades in loop

      sys11lib::ensure_key_value { 'exim_package_mask':
        file      => '/etc/portage/package.mask',
        key       => ">${exim::package}",
        delimiter => '-',
        value     => $exim::version,
        before    => Package[$exim::package],
      }
    }
  }

  package { $exim::package:
    ensure => $exim::version,
    alias  => 'exim',
  }

  if $::osfamily == 'Debian' {
    package { 'bsd-mailx':
      ensure  => present,
      require => Package[$exim::package],
    }
  }
}
