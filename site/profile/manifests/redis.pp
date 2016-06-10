class profile::redis {
  include profile::epel
  if $master {
    class {'redis':
      maxmemory => '10mb',
    }
  } else {
    class {'redis':
      maxmemory => '10mb',
      bind => $ipaddress,
      slaveof => 'master.puppetlabs.vm 6479',
    }
  }
}
