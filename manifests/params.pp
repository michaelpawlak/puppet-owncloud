# == Class owncloud::params
#
# This class is meant to be called from owncloud.
# It sets variables according to platform.
#
class owncloud::params {
  case $::osfamily {
    'Debian': {
      $install_root = '/var/www/'
      $docroot      = "${install_root}/owncloud"
      $datadir      = "${docroot}/data"
      $package_name = 'owncloud'
      $www_user     = 'www-data'
      $www_group    = 'www-data'
      $magick_pkg   = ['imagemagick']
      
      if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') >= 0) or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0)  {
        $apache_version = '2.4'
      } else {
        $apache_version = '2.2'
      }
      case $::operatingsystem {
        'Debian': {
          $apt_location       = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_${::operatingsystemmajrelease}.0/"
          $apt_gpg_remote_key = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_${::operatingsystemmajrelease}.0/Release.key"
          $apt_gpg_key        = '/etc/apt/trusted.gpg.d/owncloud.gpg'
        }
        'Ubuntu': {
          $apt_location       = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_${::operatingsystemrelease}/"
          $apt_gpg_remote_key = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_${::operatingsystemrelease}/Release.key"
          $apt_gpg_key        = '/etc/apt/trusted.gpg.d/owncloud.gpg'
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
    'RedHat': {
      $install_root = '/var/www/html'
      $docroot      = "${install_root}/owncloud"
      $datadir      = "${docroot}/data"
      $package_name = 'owncloud'
      $www_user     = 'apache'
      $www_group    = 'apache'
      $magick_pkg   = ['ImageMagick', 'ImageMagick-devel']
      $yum_descr    = "Latest stable community release of ownCloud (${::operatingsystem}_${::operatingsystemmajrelease})"
      $yum_gpg_key  = '/etc/pki/rpm-gpg/RPM-GPG-KEY-OWNCLOUD'

      if ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemrelease, '18') >= 0) or ($::operatingsystem != 'Fedora' and versioncmp($::operatingsystemrelease, '7') >= 0) {
        $apache_version = '2.4'
      } else {
        $apache_version = '2.2'
      }
      case $::operatingsystem {
        'Centos': {
          $yum_baseurl        = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/CentOS_CentOS-${::operatingsystemmajrelease}/"
          $yum_gpg_remote_key = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/CentOS_CentOS-${::operatingsystemmajrelease}/repodata/repomd.xml.key"
        }
        'RedHat': {
          $yum_baseurl        = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/RedHat_RHEL-${::operatingsystemmajrelease}/"
          $yum_gpg_remote_key = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/RedHat_RHEL-${::operatingsystemmajrelease}/repodata/repomd.xml.key"
        }
        'Fedora': {
          $yum_baseurl        = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/Fedora_${::operatingsystemmajrelease}/"
          $yum_gpg_remote_key = "http://download.opensuse.org/repositories/isv:/ownCloud:/community/Fedora_${::operatingsystemmajrelease}/repodata/repomd.xml.key"
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
  }

  # php extensions
  $php_extensions = {
    'mysql' => {
      'settings'  => {
        'extension'  => 'mysql.so'
      }
    },
    'pgsql' => {
      'settings'  => {
        'ensure'  => 'present'
      }
    },
    'sqlite3' => {
      'settings'  => {
        'ensure'  => 'present'
      }
    },
    'xml' => {},
    'gd'  => {},
    'apc' => {
      'provider'  => 'pecl',
      'settings'  => {
        'apc.stat'  => '0',
        'extension' => 'apc.so'
      }
    },
    'ldap'  => {
      'settings'  => {
        'extension' => 'ldap.so'
      }
    },
    'mbstring'  => {},
    'process' => {},
    'xmlwriter' => {
      'provider'  => 'pecl'
    },
    'intl'  => {},
    'mcrypt'  => {},
    'imagick' => {
      'provider'  => 'pecl'
    }
  }
  $php_settings = {
    'date.timezone' => 'UTC'
  }

  $php_fpm_pools = {
    'owncloud' => {
      'pm_status_path'        => '/status',
      'listen'                => '127.0.0.1:9001',
      'user'                  => $www_user,
      'group'                 => $www_group,
      'ping_path'             => '/ping',
      'catch_workers_output'  => 'yes',
      'env_value'             => {
        'PATH'          => '/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      },
      'php_value'             => {
        'date.timezone' => 'UTC'
      }
    }
  }
}
