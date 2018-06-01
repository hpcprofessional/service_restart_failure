# To demonstrate this use case:
# 1. Classify a node that uses SystemV init scripts with this class
# 2. Do a puppet run, note the PID (cat /var/run/my_service.pid)
# 4. The next puppet run, the service will fail to stop, causing Puppet to report a failure to bounce the service
# 5. Subsequent puppet runs don't try to manage the service, but it is running under the old PID with the old config
# 6. This is bad, because Puppet didn't guarantee the end state, nor did it report on it appropriately. 

# The end result is that Admins would have to start and stop the service across their entire estate (via tasks, perhaps?) to know that things are in their proper state.

class service_restart_failure (
  $fail_to_restart = false,
) {

  $content = $fail_to_restart ? { 
    false => 'run',
    default => 'crash',
  }

  file { 'my_service init script' :
    ensure => file,
    path   => '/etc/init.d/my_service',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/service_restart_failure/my_service',
    notify  => Service['my_service'],
  }

  file { 'my_service conf file' :
    ensure  => file,
    path    => '/etc/my_service.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
    notify  => Service['my_service'],
  }

  service { 'my_service' :
    provider  => 'init',
    ensure    => running,
    enable    => true,
  }

}
