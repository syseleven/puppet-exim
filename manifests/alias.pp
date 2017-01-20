# Class exim::alias
#
# this class is called via init.pp
#
class exim::alias (
  $aliases,
  $aliases_target,
  $postmaster,
) {
  if $aliases {
    $aliases_keys = keys($aliases)
    exim::aliases_set { $aliases_keys:
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
  exim::aliases_set { $default_aliases_keys:
    aliases_target => $aliases_target,
    aliases        => $default_aliases,
  }

  exec { 'newaliases':
    command     => 'newaliases',
    path        => '/usr/sbin/:/usr/bin/',
    refreshonly => true,
  }
}
