user { 'kentaro':
  shell      => '/bin/zsh',
  password   => '$1$EdHH7egO$Q9ieV8QoLADBt.EYKrg0T1',
  home       => '/home/kentaro',
  managehome => true,
  require    => Package['zsh'],
}

package { 'zsh':
  ensure => 'present',
}
