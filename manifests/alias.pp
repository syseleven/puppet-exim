# Class exim::alias
#
# this class is called via init.pp
#
class exim::alias () {

  # Define exim::alias::aliases_set
  #
  define aliases_set($aliases = undef) {
    sys11lib::ensure_key_value { $name:
      file      => $exim::params::aliases_target,
      key       => "$name:",
      value     => $aliases[$name],
      delimiter => ' ',
      notify    => Exec['newaliases'],
    }
  }

  if $exim::aliases {
    $aliases_keys = keys($exim::aliases)
    aliases_set { $aliases_keys:
      aliases => $exim::aliases,
    }
  }

  # setup default aliases, use same set aliases

  $default_aliases = {
    'root'     => $exim::postmaster,
    'apache'   => $exim::postmaster,
    'nginx'    => $exim::postmaster,
    'devnull'  => '/dev/null'
  }
  $default_aliases_keys = keys($default_aliases)
  aliases_set { $default_aliases_keys:
    aliases => $default_aliases,
  }

  exec { 'newaliases':
    command     => 'newaliases',
    path        => '/usr/sbin/:/usr/bin/',
    refreshonly => true,
  }

}
