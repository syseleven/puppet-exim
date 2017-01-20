# Define exim::aliases_set
#
define exim::aliases_set(
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


