# == Class owncloud::install::tarball
#
# Puppet class to install owncloud via tarball
# Class called from ::owncloud::install
#
class owncloud::install::tarball inherits ::owncloud::install {

  # only install if defined
  if $install_tarball {

    # create the install root if it isn't already defined
    if ! defined(File[$install_root]) {
      file { "${install_root}":
        ensure  => 'directory'
      }
    }

    # if install source is empty use a default
    if ! $install_source {
      $install_source = "https://download.owncloud.org/community/owncloud-${install_version}.tar.bz2"
    }

    # get the gpg key for owncloud
    exec { 'get_owncloud_tarball':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      command => "wget -O /tmp/owncloud.tar.bz2 ${install_source}",
      creates => '/tmp/owncloud.tar.bz2',
      unless  => "test -d ${install_root}/owncloud",
      notify  => Exec['extract_owncloud']
    }

    # extract owncloud taball
    exec { 'extract_owncloud':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      command => "tar -xjf /tmp/owncloud.tar.bz2 -C ${install_root}",
      creates => '/tmp/owncloud.tar.bz2',
      notify  => Exec['purge_owncloud_tarball'],
      require => Exec['get_owncloud_tarball']
    }

    # extract owncloud taball
    exec { 'purge_owncloud_tarball':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      command => 'rm -f /tmp/owncloud.tar.bz2',
      onlyif  => 'test -f /tmp/owncloud.tar.bz2',
      notify  => Exec['chown_owncloud'],
      require => Exec['extract_owncloud']
    }

    # extract owncloud taball
    exec { 'chown_owncloud_docroot':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      command => "chown -R ${www_user}.${www_group} ${docroot}",
      creates => '/tmp/owncloud.tar.bz2',
      require => Exec['purge_owncloud_tarball']
    }
  }
}