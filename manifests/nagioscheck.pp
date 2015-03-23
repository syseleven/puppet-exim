# Class: exim::nagioscheck
#
# This class can be called directly, if you only want do have nagios and zabbix
# handled. Therefore we dont use variables from the params scope.
#
# When using main class, use varibales in there. Vars are then passed to this
# class.
#
class exim::nagioscheck (
  $service = $exim::params::service,
  $warn_limit = 100,
  $crit_limit = 1000,
  $logfile = $exim::params::logfile,
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
) inherits exim::params {

  if defined(Class[nagios::nrpe]) {

    #needed to have nagios::nrpe::plugindir loaded before using
    include nagios::nrpe

    nagios::nrpecmd { 'check_smtp':
      cmd => "${nagios::nrpe::plugindir}/check_smtp -H localhost",
    }
    nagios::nrpecmd { 'check_mailq':
      cmd => "${nagios::nrpe::plugindir}/check_mailq -w ${warn_limit} -c ${crit_limit} -M exim",
    }

    if ! defined(Nagios::Register_hostgroup['mailq']) {
      nagios::register_hostgroup { 'mailq': }
    }
    if ! defined(Nagios::Register_hostgroup['smtp']) {
      nagios::register_hostgroup { 'smtp':  }
    }

  }

  if $::operatingsystem != 'Solaris' and $::sys11_gentoo_frozen != 'frozen' {
    if defined(Class['zabbix_agent']) {
      zabbix_agent::template { 'exim': }
      zabbix_agent::config_snippet::snippet_set { 'exim':
        content => "UserParameter=get_mailcount,/usr/local/bin/get_mailcount --logfile ${logfile}\nUserParameter=mailqueue,/usr/sbin/exim -bpc",
      }
    }

    augeas { 'is_nagios_mail_member':
      context => '/files/etc/group',
      onlyif  => 'match /files/etc/group/mail size != 0',
      notify  => Service['nrpe'],
      changes => [
        'set /files/etc/group/mail/user[.=\'nagios\'] nagios'
      ],

    }

    # On Debian, the nagios-user _also_ needs to be in Debian-exim group for mailq
    if $::osfamily == 'Debian' {
      augeas { 'is_nagios_debian-exim_member':
        context => '/files/etc/group',
        onlyif  => 'match /files/etc/group/Debian-exim size != 0',
        notify  => Service['nrpe'],
        changes => [
          'set /files/etc/group/Debian-exim/user[.=\'nagios\'] nagios'
        ],

      }
    }

    file { '/usr/local/bin/get_mailcount':
      mode   => '0555',
      source => 'puppet:///modules/exim/get_mailcount',
    }
  }

  if defined(Class['monit']) {
    monit::check_process::process_set { 'exim':
      ensure => $monit_check,
      pid    => "/var/run/${service}.pid",
      start  => "/etc/init.d/${service} restart",
      stop   => "/etc/init.d/${service} stop",
      tests  => $monit_tests,
    }
  }

}
