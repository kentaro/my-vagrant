exec { 'epel':
  command => 'rpm -Uvh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm',
  path    => '/bin',
  unless  => 'rpm -qa | grep epel-release',
}

exec { 'puppet':
  require => Exec['epel'],
  command => 'yum -y downgrade puppet --enablerepo=epel puppet',
  path    => '/usr/bin',
}

exec { 'puppet-server':
  require => Exec['epel'],
  command => 'yum -y install puppet-server --enablerepo=epel',
  path    => '/usr/bin',
}

service { 'puppetmaster':
  require => Exec['puppet-server'],
  ensure  => running,
}
