
## packages

$gen_packs = ['build-essential','gcj-jdk']
package { $gen_packs:
  ensure => latest,
}

## webserver w/ ssl
class { 'nginx': }

nginx::resource::vhost { 'localhost':
  www_root => '/var/www/html',
  ssl      => true,
}

## elasticsearch
include elasticsearch

## Java

file { '/home/kultar/datetime':
  ensure => present,
  source => 'puppet:///modules/java/datetime',
}

cron { 'java_datetime':
  command => '/home/kultar/datetime  > /tmp/cron.log 2>&1',
  user    => root,
  minute  => 5,
  require => File['/home/kultar/datetime'],
}

## postgress 9.4.4 db:scorecard user:scorecard

class { 'postgresql::server':
  version => '9.4.4',
}

postgresql::server::db { 'scorecard':
  user     => 'scorecard',
  password => postgresql_password('scorecard', 'scorecard'),
}

## iptables 22,80,443 allow

class { 'firewall': }

firewall { 'ssh port':
  port   => '22',
  proto  => tcp,
  action => accept,
}

firewall { 'http port':
  port   => '80',
  proto  => tcp,
  action => accept,
}

firewall { 'httpS port':
  port   => '443',
  proto  => tcp,
  action => accept,
}


## docker, attach aufs
include docker

## lvm on additional disk
lvm::volume { 'lvm_vol':
  ensure => present,
  vg     => 'lvm_vg',
  pv     => '/dev/hdb',
  fstype => 'ext3',
  size   => '20G', ###UPDATE THIS SIZE
}

## wpscan securityscorecard.io and 

## all services on 10.0.1.240, first 6k ports
