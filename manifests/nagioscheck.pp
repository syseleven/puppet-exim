# Class: exim::nagioscheck
#
# This class can be called directly, if you only want do have nagios and zabbix
# handled. Therefore we dont use variables from the params scope.
#
# When using main class, use varibales in there. Vars are then passed to this
# class.
#
class exim::nagioscheck (
  $warn_limit = 100,
  $crit_limit = 1000,
  $logfile = $exim::params::logfile,
  $smtp_hostname = 'localhost',
  $smtp_ip_family = 'inet',
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $service = $exim::params::service,
  $pid = $exim::params::pid,
) inherits exim::params {

  if defined(Class[nagios::nrpe]) {

    #needed to have nagios::nrpe::plugindir loaded before using
    include nagios::nrpe

    case $smtp_ip_family {
      'inet':   { $check_smtp_ip_family = '-4' }
      'inet6':  { $check_smtp_ip_family = '-6' }
      'any':    { $check_smtp_ip_family = undef }
      default: { fail('You must specify either \'inet\', \'inet6\' or \'any\' for exim::nagioscheck::smtp_ip_family') }
    }
    $check_smtp_options = join(delete_undef_values([$check_smtp_ip_family,'-H',$smtp_hostname]),' ')
    nagios::nrpecmd { 'check_smtp':
      cmd => "${nagios::nrpe::plugindir}/check_smtp ${check_smtp_options}",
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

      if $::osfamily == 'Debian' {
        exec { 'add_zabbix_to_Debian-exim_group':
          path    => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless  => 'getent group Debian-exim | grep -q zabbix',
          command => 'usermod -aG Debian-exim zabbix',
          notify  => Service['zabbix-agentd'],
        }
      } else {
        exec { 'add_zabbix_to_mail_group':
          path    => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless  => 'getent group mail | grep -q zabbix',
          command => 'usermod -aG mail zabbix',
          notify  => Service['zabbix-agentd'],
        }
      }
    }

    include nagios::nrpe
    exec { 'add_nagios_to_mail_group':
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      unless  => "getent group mail | grep -q ${nagios::params::nagios_user}",
      command => "usermod -aG mail ${nagios::params::nagios_user}",
      notify  => Service['nrpe'],
    }

    # On Debian, the nagios-user _also_ needs to be in Debian-exim group for mailq
    if $::osfamily == 'Debian' {
      exec { 'add_nagios_to_Debian-exim_group':
        path    => '/bin:/usr/bin:/sbin:/usr/sbin',
        unless  => "getent group Debian-exim | grep -q ${nagios::params::nagios_user}",
        command => "usermod -aG Debian-exim ${nagios::params::nagios_user}",
        notify  => Service['nrpe'],
      }
    }

    file { '/usr/local/bin/get_mailcount':
      mode   => '0555',
      source => 'puppet:///modules/exim/get_mailcount',
    }
  }

  if defined(Class['monit']) {
    monit::check_process::process_set { $service:
      ensure => $monit_check,
      tests  => $monit_tests,
      pid    => $pid,
    }
  }

}
