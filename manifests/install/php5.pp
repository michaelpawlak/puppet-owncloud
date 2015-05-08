# == Class owncloud::install::php5
#
# Puppet class to install and configure php
# Class called from ::owncloud::install
#
class owncloud::install::php5 inherits ::owncloud::install {

  # configure php
  if $manage_php {
    class { 'php':
      settings    => $php_settings,
      extensions  => $php_extensions,
      fpm         => false
    }

    # configure php::fpm
    class { 'php::fpm':
      ensure    => $php_fpm_ensure,
      settings  => $php_fpm_settings,
      pools     => $php_fpm_pools
    }

    if $php_fpm_ensure == 'absent' {
      class { 'php::fpm::service':
        ensure  => 'stopped',
        enable  => false
      }
    }
  }
}