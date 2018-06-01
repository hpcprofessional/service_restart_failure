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
