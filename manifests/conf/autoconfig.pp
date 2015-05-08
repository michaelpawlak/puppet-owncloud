# == Class owncloud::conf::autoconfig
#
# Puppet class to configure owncloud autoconfig.php
# This class is called from owncloud::conf
#
class owncloud::conf::autoconfig inherits ::owncloud::conf {

  # setup the autoconfig.php file
  file { "${docroot}/config/autoconfig.php":
    ensure  => present,
    mode    => '0750',
    owner   => $www_user,
    group   => $www_group,
    content => template('owncloud/autoconfig.php.erb'),
  }
}