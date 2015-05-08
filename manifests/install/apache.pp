# == Class: owncloud::install::apache
#
# Puppet class to configure apache for owncloud.
# Class called from ::owncloud::install
#
class owncloud::install::apache inherits ::owncloud::install {
  
  # include apache and the desired modules
  if $manage_apache {
    include ::apache, ::apache::mod::php, ::apache::mod::rewrite, ::apache::mod::ssl

    if "${install_root}/owncloud" != $docroot {
      if ! defined(File[$docroot]) {
        file { "${docroot}":
          ensure  => link,
          target  => "${install_root}/owncloud"
        }
      }
    }
  }
}