# == Class: owncloud::install::extras
#
# Puppet class to install extra packages for owncloud.
# Class called from ::owncloud::install
#
class owncloud::install::extras inherits ::owncloud::install {

  # install smbclient
  if $install_smbclient {
    package { 'smbclient':
      ensure  => 'installed'
    }
  }

  # install libreoffice
  if $install_libreoffice {
    package { 'libreoffice':
      ensure  => 'installed'
    }
  }

  package { $magick_pkg:
    ensure  => 'installed'
  }
}