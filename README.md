# Exim

Sets up the Exim MTA.

* [Official documentation](http://www.exim.org/exim-html-current/doc/html/spec_html/index.html)
* Exim puppet module [changelog](CHANGELOG)

## exim::init

Base class to use the exim module.

### Examples

```yaml
# Adminserver with mailrelay
exim:
  postmaster: 'agent@agentur.de'
  role: 'admin'
  aliases:
    oxid: 'shopware@domain.tld'
    example: 'foo@domain.tld'
  template_vars:
    'extract_addresses_remove_arguments': false

# Sattelite (slave) with smarthost auth
exim:
  role: slave
  postmaster: foo@bar.tld
  enable_nagioscheck: false
  smarthost_auth: true
  adminserver: smtp.domain.net
  smarthost_port: 587
  smarthost_user: foo
  smarthost_password: bar
  smarthost_interface: "%{::ipaddress_eth1}"

# Adminserver as smarthost ####

exim:
  role: slave
  postmaster: webserver@example.org
  primary_hostname: admin.example.org
  adminserver: relayhost@example.org
  rewrite_targets:
    - '^(.*)@(.*)example\$ no_reply@example.org sfF'
  relay_from_hosts: 10.42.42.0/24
```

### Parameters

```ruby
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
    $template_vars = {}
      extra custom parameters for the config file  
    $smarthost_auth = false
      En- or disable smarthost auth
    $smarthost_user = false
      Define smarthost auth user
    $smarthost_password = false
      Define smarthost auth password
    $smarthost_interface = false
      Define IP over which interface the smarthots shall be connected
    $smarthost_connection_max_messages = 100
    $smarthost_port = 25
      Define connect port of smarthost
```

### Troubleshooting

Common errors and how they can be solved

#### Exim keep_environment

```yaml
exim:
  keep_environment: false # entferne Parameter für exim <= 4.85 bzw. 4.82-3ubuntu2

# Alternativ
exim:
  keep_environment: "" # erzwinge Parameter ohne Wert für exim >= 4.86 bzw. 4.82-3ubuntu2.1
```

## exim::nagioscheck

Configure monitoring for for Exim mailservices

### Examples

```yaml
# check smtp on IPv6 address for localhost
exim::nagioscheck:
  smtp_ip_family: 'inet6'

# check smtp on custom hostname
exim::nagioscheck:
  smtp_hostname: 'example.com'

# Use custom logfile
exim::nagioscheck:
  logfile: '/var/log/exim4/smtp_error.log'

# Customize mailq monitoring limits
exim::nagioscheck:
  warn_limit: 500
  crit_limit: 3000
```

### Parameters

```ruby
  $warn_limit = 100,
  $crit_limit = 1000,
    MailQ monitoring limits
  $logfile = $exim::params::logfile,
    Logfile to check for errors
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $service = $exim::params::service,
    Servicename monit will monitor
  $smtp_hostname = 'localhost',
  $smtp_ip_family = 'inet',
    SMTP check network config, allowed values: 'inet','inet6','any', defaults to 'inet'
```
