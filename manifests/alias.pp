# Class exim::alias
#
# this class is called via init.pp
#
class exim::alias (
  $aliases,
  $aliases_target,
  $postmaster,
  ) {

  # Define exim::alias::aliases_set
  #
  define aliases_set(
    $aliases_target,
    $aliases = undef
  ) {
    sys11lib::ensure_key_value { $name:
      file      => $aliases_target,
      key       => "${name}:",
      value     => $aliases[$name],
      delimiter => ' ',
      notify    => Exec['newaliases'],
    }
  }

  if $aliases {
    $aliases_keys = keys($aliases)
    aliases_set { $aliases_keys:
      aliases_target => $aliases_target,
      aliases        => $aliases,
    }
  }

  # setup default aliases, use same set aliases

  $default_aliases = {
    'root'     => $postmaster,
    'apache'   => $postmaster,
    'nginx'    => $postmaster,
    'www-data' => $postmaster,
    'devnull'  => '/dev/null'
  }
  $default_aliases_keys = keys($default_aliases)
  aliases_set { $default_aliases_keys:
    aliases_target => $aliases_target,
    aliases        => $default_aliases,
  }

  exec { 'newaliases':
    command     => 'newaliases',
    path        => '/usr/sbin/:/usr/bin/',
    refreshonly => true,
  }

}
