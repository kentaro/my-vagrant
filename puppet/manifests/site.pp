exec { 'epel':
  command => 'rpm -Uvh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm',
  path    => '/bin',
  unless  => 'rpm -qa | grep epel-release',
}

exec { 'puppet':
  require => Exec['epel'],
  command => 'yum -y downgrade puppet --enablerepo=epel',
  path    => '/usr/bin',
}

exec { 'puppet-server':
  require => Exec['epel'],
  command => 'yum -y install puppet-server --enablerepo=epel',
  path    => '/usr/bin',
}

file { '/etc/puppet/puppet.conf':
  require => Exec['puppet-server'],
  mode    => 0644,
  content => '[main]
    manifestdir = $confdir/shared/manifests

    logdir = /var/log/puppet
    rundir = /var/run/puppet
[agent]
    classfile = $vardir/classes.txt
    localconfig = $vardir/localconfig
  ',
}

file { '/etc/puppet/fileserver.conf':
  require => Exec['puppet-server'],
  mode    => 0644,
  content => '[mount_point]
    path /etc/puppet/shared
    allow *
  ',
}

service { 'puppetmaster':
  require => [
    File['/etc/puppet/puppet.conf'],
    File['/etc/puppet/fileserver.conf'],
  ],
  ensure  => running,
}
