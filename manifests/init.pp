# == Class: owncloud
#
# Puppet class to install and configure ownCloud.
#
class owncloud (
  ## Database Settings ##
  $manage_db            = true,
  $db_host              = 'localhost',
  $db_name              = 'owncloud',
  $db_pass              = 'owncloud',
  $db_user              = 'owncloud',
  $db_type              = 'mysql',
  $db_table_prefix      = '',
  $db_driver_options    = undef,
  
  ## Install Settings ##
  $install_git          = false,
  $install_tarball      = false,
  $install_source       = undef,
  $install_version      = '8.0.2',
  $install_root         = $::owncloud::params::install_root,
  $install_package      = true,
  $manage_repo          = true,
  $apt_location         = $::owncloud::params::apt_location,
  $apt_gpg_remote_key   = $::owncloud::params::apt_gpg_remote_key,
  $yum_baseurl          = $::owncloud::params::yum_baseurl,
  $yum_gpg_remote_key   = $::owncloud::params::yum_gpg_remote_key,

  ## Extra Install Settings ##
  $install_smbclient    = false,
  $install_libreoffice  = false,

  ## PHP Settings ##
  $manage_php           = true,
  $php_extensions       = $::owncloud::params::php_extensions,
  $php_settings         = $::owncloud::params::php_settings,
  $php_fpm_ensure       = 'absent',
  $php_fpm_settings     = {},
  $php_fpm_pools        = $::owncloud::params::php_fpm_pools,

  ## Application Settings ##
  $admin_user           = undef,
  $admin_pass           = undef,
  $datadir              = $::owncloud::params::datadir,
  $manage_skeleton      = true,

  ## Apache Settings ##
  $manage_apache        = true,
  $http_port            = '80',
  $https_port           = '443',
  $www_user             = $::owncloud::params::www_user,
  $www_group            = $::owncloud::params::www_group,
  $docroot              = $::owncloud::params::docroot,
  $manage_vhost         = true,
  $ssl                  = false,
  $ssl_ca               = undef,
  $ssl_cert             = undef,
  $ssl_chain            = undef,
  $ssl_key              = undef,
  $url                  = "owncloud.${::domain}",
  $serveraliases        = undef,
  $datadir              = $::owncloud::params::datadir,

  ## Config Settings ##
  $language             = 'en',
  $default_app          = 'files',
  $knowledgebase_enable = true,
  $enable_avatars       = true,
  $change_display_names = true,
  $session_keepalive    = true,
  $user_backends        = undef,
  $mail_domain          = $::domain,
  $mail_user            = 'owncloud',
  $mail_smtpmode        = 'sendmail',
  $config_hash          = {},
  ) inherits ::owncloud::params {

  # define some variables for validation
  $install_root_base = dirname($install_root)
  $datadir_base = dirname($datadir)
  $docroot_base = dirname($docroot)
  $datadir_base = dirname($datadir)

  # validate database settings
  validate_bool($manage_db)
  validate_re($db_host,
    '^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$',
    '$db_host must be a valid hostname or IP')
  validate_string($db_name)
  validate_string($db_pass)
  validate_string($db_user)
  if $manage_db {
    validate_re($db_type, ['mysql'],
      '$db_type must be \'mysql\' if $manage_db is true')
  }
  validate_re($db_type, ['mysql', 'pgsql', 'sqlite'])
  if $db_driver_options {
    validate_array($db_driver_options)
  }

  # validate install settings
  validate_bool($install_git)
  validate_bool($install_tarball)
  validate_bool($install_source)
  validate_string($install_version)
  validate_absolute_path($install_root_base,
    'base directory for $install_root must be present on file system')
  validate_bool($install_package)
  validate_bool($manage_repo)
  validate_re($apt_location,
    '^((((https?):\/\/))(%[0-9A-Fa-f]{2}|[-()_.!~*\';\/?:@&=+$,A-Za-z0-9])+)([).!\';\/?:,][[:blank:]])?$',
    '$apt_location must be a valid http(s) URL')
  validate_re($apt_gpg_remote_key,
    '^((((https?):\/\/))(%[0-9A-Fa-f]{2}|[-()_.!~*\';\/?:@&=+$,A-Za-z0-9])+)([).!\';\/?:,][[:blank:]])?$',
    '$apt_gpg_remote_key must be a valid http(s) URL')
  validate_re($yum_location,
    '^((((https?):\/\/))(%[0-9A-Fa-f]{2}|[-()_.!~*\';\/?:@&=+$,A-Za-z0-9])+)([).!\';\/?:,][[:blank:]])?$',
    '$yum_location must be a valid http(s) URL')
  validate_re($yum_gpg_remote_key,
    '^((((https?):\/\/))(%[0-9A-Fa-f]{2}|[-()_.!~*\';\/?:@&=+$,A-Za-z0-9])+)([).!\';\/?:,][[:blank:]])?$',
    '$yum_gpg_remote_key must be a valid http(s) URL')

  # validate extra install settings
  validate_bool($install_smbclient)
  validate_bool($install_libreoffice)

  # validate php settings
  validate_bool($manage_php)
  if $manage_php {
    validate_hash($php_extensions)
    validate_re($php_fpm_ensure, ['absent', 'ensure'])
    validate_hash($php_fpm_settings)
    validate_hash($php_fpm_pools)
  }

  # validate application settings
  if $admin_user {
    validate_string($admin_user)
  }
  if $admin_pass {
    validate_string($admin_pass)
  }
  validate_absolute_path($datadir_base)
  validate_bool($manage_skeleton)

  # validate apache settings
  validate_bool($manage_apache)
  if $manage_apache {
    validate_re($http_port, '^[1-9]\d*$', '$http_port must be a postive integer')
    validate_re($https_port, '^[1-9]\d*$', '$https_port must be a postive integer')
    validate_string($www_user)
    validate_string($www_group)
    validate_absolute_path($docroot_base)
    validate_bool($manage_vhost)

    # validate vhost settings
    if $manage_vhost {
      validate_bool($ssl)

      # validate ssl settings
      if $ssl {

        # validate ssl_ca variable
        if $ssl_ca {
          $ssl_ca_base = dirname($ssl_ca)
          validate_absolute_path($ssl_ca_base)
          if ! defined(File[$ssl_ca]) {
            warn("${ssl_ca} is not defined in puppet. You may want to add this configuration")
          }
        }

        # validate ssl_cert variable
        if $ssl_cert {
          $ssl_cert_base = dirname($ssl_cert)
          validate_absolute_path($ssl_cert_base)
          if ! defined(File[$ssl_cert]) {
            warn("${ssl_cert} is not defined in puppet. You may want to add this configuration")
          }
        }

        # validate ssl_ca variable
        if $ssl_chain {
          $ssl_chain_base = dirname($ssl_chain)
          validate_absolute_path($ssl_chain_base)
          if ! defined(File[$ssl_chain]) {
            warn("${ssl_chain} is not defined in puppet. You may want to add this configuration")
          }
        }

        # validate ssl_ca variable
        if $ssl_key {
          $ssl_key_base = dirname($ssl_key)
          validate_absolute_path($ssl_key_base)
          if ! defined(File[$ssl_key]) {
            warn("${ssl_key} is not defined in puppet. You may want to add this configuration")
          }
        }
      }

      validate_re($url,
        '^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$',
        '$url must be a valid hostname (domain) or IP')
      if $serveraliases {
        validate_array($serveraliases)
      }
      validate_absolute_path($datadir_base)
    }
  }

  anchor { 'owncloud::begin': } ->
  class { '::owncloud::install': }
  class { '::owncloud::conf': } ->
  anchor { 'owncloud::end': }
}
