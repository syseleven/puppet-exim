# Exim

Sets up the Exim MTA.

* [Official documentation](http://www.exim.org/exim-html-current/doc/html/spec_html/index.html)
* Exim puppet module [changelog](CHANGELOG)

### Parameters

    $role
      Set role to admin or slave
      The role 'management_platform' is for Ubuntu hosts in the Management Platform 
        which use smtp.syseleven.net for outgoing mail
    $postmaster
      Sets mailallias address for root, apache, nginx
    $package = $exim::params::package
    $service = $exim::params::service
    $version = 'latest'
    $useflags = ''
      Sets Gentoo useflags for exim package
    $adminserver = ''
      Only used for role=slave, defines the IP/DNS of adminserver to relay over
    $aliases = undef,
      List for /etc/mail/aliases
    $warn_limit = 100
    $crit_limit = 100
    $logfile = $exim::params::logfile,
      file for exim standard log, currently only for nagios/zabbix
    $monit_check = 'present',
      or 'absent' to remove check
    $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
      Now following the exim.conf variables:
    $tls_advertise_hosts = false
    $tls_certificate = false
    $tls_privatekey = false
    $maildomain = '@'
      Used for local_domains
    $primary_hostname = '$::fqdn'
      Used for primary_hostname
    $rewrite_targets = []
    $trusted_users = []
      list of of trusted users
      automatically put 'apache' and 'nginx' if those puppet modules are loaded
    $relay_from_internal_network = true
      if set to true, then the internal_network (/24) is allowed to relay over this host
    $relay_from_hosts = [],
      string or list
      additional hosts to allow relaying
    $enable_nagioscheck = true
      enable nagios and zabbix check
    $template_vars = undef
      extra custom parameters for the config file  


### Sample usage

    exim:
      postmaster: 'agent@agentur.de'
      role: 'admin'
      aliases:
        oxid: 'shopware@domain.tld'
        example: 'foo@domain.tld'
      template_vars:
        'extract_addresses_remove_arguments': false
