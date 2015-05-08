# == Class owncloud::conf::base
#
# Puppet class to configure base directories for owncloud
# This class is called from owncloud::conf
#
class owncloud::conf::base inherits ::owncloud::conf {

  # create the datadir
  if ! defined(File[$datadir]) {

    $datadir_root = dirname($datadir)

    if ! defined(File[$datadir_root]) {
      file { "${datadir_root}":
        ensure  => directory,
        owner   => $www_user,
        group   => $www_user,
        mode    => '0755'
      }      
    }    

    file { "${datadir}":
      ensure  => directory,
      owner   => $www_user,
      group   => $www_user,
      mode    => '0755'
    }
  }

  # create our skeleton directories
  if $manage_skeleton {
    # Delete existing skeleton dirs
    file { [
      "${docroot}/core/skeleton/documents",
      "${docroot}/core/skeleton/music",
      "${docroot}/core/skeleton/photos",
      "${docroot}/core/skeleton/welcome.txt"
      ]:
      ensure  => 'absent',
      force   => true
    }

    # create new skeleton dirs
    file { [
      "${docroot}/core/skeleton/Documents",
      "${docroot}/core/skeleton/Music",
      "${docroot}/core/skeleton/Photos"
      ]:
      ensure  => 'directory',
      mode    => '0770',
      owner   => $www_user,
      group   => $www_group,
    }

    # include owncloud user manual
    file { "${docroot}/core/skeleton/ownCloudUserManual.pdf":
      ensure  => 'file',
      mode    => '0440',
      owner   => $www_user,
      group   => $www_group,
      source  => 'puppet:///modules/owncloud/ownCloudUserManual.pdf'
    }
  }
}