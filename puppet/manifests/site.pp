package { 'git': }

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

file    { '/var/lib/puppet/modules':
  ensure => directory,
}

exec { "install puppetlabs-vcsrepo":
  require => [Package["git"], File["/var/lib/puppet/modules"]],
  command => "git clone git://github.com/puppetlabs/puppetlabs-vcsrepo.git",
  path    => '/usr/bin',
  cwd     => '/var/lib/puppet/modules',
  unless  => "test -d /var/lib/puppet/modules/puppetlabs-vcsrepo",
}

exec { 'puppet-server':
  require => Exec['epel'],
  command => 'yum -y install puppet-server --enablerepo=epel',
  path    => '/usr/bin',
}

file { '/etc/puppet/puppet.conf':
  require => Exec['puppet-server'],
  mode    => 0644,
  content => '
[main]
    logdir = /var/log/puppet
    rundir = /var/run/puppet
[agent]
    classfile = $vardir/classes.txt
    localconfig = $vardir/localconfig
    pluginsync  = true
[master]
    manifestdir = $confdir/shared/manifests
    modulepath  = $confdir/shared/modules:$vardir/modules
    templatedir = $confdir/shared/templates
  ',
}

file { '/etc/puppet/fileserver.conf':
  require => Exec['puppet-server'],
  mode    => 0644,
  content => '[dist]
    path /etc/puppet/shared/dist
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

# これがないと$lsbmajdistreleaseとかが使えない
package { 'redhat-lsb': }
