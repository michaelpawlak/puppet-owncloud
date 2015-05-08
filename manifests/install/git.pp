# == Class owncloud::install::git
#
# Puppet class to install owncloud via git
# Class called from ::owncloud::install
#
class owncloud::install::git inherits ::owncloud::install {

  # only install if defined
  if $install_git {

    # create the install root if it isn't already defined
    if ! defined(File[$install_root]) {
      file { "${install_root}":
        ensure  => 'directory'
      }
    }

    # if install source is empty use a default
    if ! $install_source {
      $install_source = "https://github.com/owncloud/core.git"
    }

    # verify set the install verison to the proper format
    if $install_version =~ '^(\d+\.)?(\d+\.)?(\*|\d+)$' {
      $install_git_version = "v${install_version}"
    }
    else {
      $install_git_version = $install_version
    }

    # determine the proper installation path
    if $install_root != dirname($docroot) {
      $install_git_root = "${install_root}/owncloud"
    }
    else {
      $install_git_root = $docroot
    }

    # install the git repo
    vcsrepo { "${install_git_root}":
      ensure    => latest,
      provider  => git,
      source    => $install_source,
      owner     => $www_user,
      group     => $www_group,
      revision  => $install_git_version
    }
  }
}