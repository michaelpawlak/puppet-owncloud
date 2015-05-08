# == Class owncloud::install::package
#
# Puppet class to install owncloud via apt or yum
# Class called from ::owncloud::install
#
class owncloud::install::package inherits ::owncloud::install {
  
  if $install_package {
    if $manage_repo {
      case $::osfamily {
        'Debian': {

          # include apt module
          include ::apt

          # get the gpg key for owncloud
          exec { 'get_gpg_owncloud':
            path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
            command => "wget -O $apt_gpg_key $apt_gpg_remote_key",
            creates => $apt_gpg_key,
            notify  => Exec['import_gpg_owncloud']
          }

          # import the gpg key fpr owncloud
          exec { 'import_gpg_owncloud':
            path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
            command => "apt-key add ${apt_gpg_key}",
            unless  => "apt-key list | grep ${apt_gpg_key}",
            require => Exec['get_gpg_owncloud']
          }

          # configure the apt repo
          apt::source { 'owncloud':
            location    => $apt_location,
            release     => '',
            repos       => '/',
            include_src => false,
            key         => 'BA684223',
            key_source  => $apt_gpg_key
          }
        }
        'RedHat': {

          # get the gpg key for owncloud
          exec { 'get_gpg_owncloud':
            path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
            command => "wget -O $yum_gpg_key $yum_gpg_remote_key",
            creates => $yum_gpg_key,
            notify  => Exec['import_gpg_owncloud']
          }

          # import the gpg key fpr owncloud
          exec { 'import_gpg_owncloud':
            path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
            command => "rpm --import $yum_gpg_key",
            unless  => "rpm -q gpg-pubkey-$(echo $(gpg --throw-keyids < $yum_gpg_key) | cut --characters=11-18 | tr '[A-Z]' '[a-z]')",
            require => Exec['get_gpg_owncloud']
          }

          # configure the yum repo
          yumrepo { 'owncloud':
            ensure    => 'present',
            descr     => $yum_descr,
            baseurl   => $yum_baseurl,
            gpgcheck  => '1',
            gpgkey    => "file://$yum_gpg_key",
            enabled   => '1'
          }
        }
        default: {

          # fail if the osfamily isn't supported
          fail("${::osfamily} not supported")
        }
      }

      if $::osfamily == 'Debian' {

        # install our package
        package { $::owncloud::package_name:
          ensure  => present,
          require => Apt::Source['owncloud']
        }
      }
      elsif  $::osfamily == 'RedHat' {

        # install our package
        package { $::owncloud::package_name:
          ensure  => present,
          require => Yumrepo['owncloud']
        }
      }
      else {

        # fail if the osfamily isn't supported
        fail("$::osfamily not supported")
      }
    }
  }
}