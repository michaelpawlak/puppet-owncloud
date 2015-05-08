# == Class owncloud::conf::apache
#
# Puppet class to configure apache
# This class is called from owncloud::conf
#
class owncloud::conf::apache inherits ::owncloud::conf {

  # configure our virtual host
  if $manage_vhost {
    # generic directory settings
    $vhost_directories_common = {
        path            => $docroot,
        options         => ['Indexes', 'FollowSymLinks', 'MultiViews'],
        allow_override  => 'All',
        custom_fragment => 'Dav Off',
      }

    # additional directory settings based on apache_version
    if $apache_version == '2.2' {
      $vhost_directories_version = {
        order   => 'allow,deny',
        allow   => 'from All',
        satisfy => 'Any',
      }
    } else {
      $vhost_directories_version = {
        require => 'all granted'
      }
    }

    # compile directory into single hash
    $vhost_directories = merge($vhost_directories_common, $vhost_directories_version)

    if $ssl {
      # configure non ssl vhost
      apache::vhost { 'owncloud-http':
        manage_docroot  => false,
        servername      => $url,
        serveraliases   => $serveraliases,
        port            => $http_port,
        docroot         => $docroot,
        rewrites        => [
          {
            comment      => 'redirect non-SSL traffic to SSL site',
            rewrite_cond => ['%{HTTPS} off'],
            rewrite_rule => ['(.*) https://%{HTTP_HOST}%{REQUEST_URI}'],
          }
        ]
      }

      # configure ssl vhost
      apache::vhost { 'owncloud-https':
        manage_docroot  => false,
        servername      => $url,
        serveraliases   => $serveraliases,
        port            => $https_port,
        docroot         => $docroot,
        directories     => $vhost_directories,
        ssl             => true,
        ssl_ca          => $ssl_ca,
        ssl_cert        => $ssl_cert,
        ssl_chain       => $ssl_chain,
        ssl_key         => $ssl_key,
      }
    }
    else {
      # configure non ssl vhost
      apache::vhost { 'owncloud':
        manage_docroot  => false,
        servername      => $url,
        serveraliases   => $serveraliases,
        port            => $http_port,
        docroot         => $docroot,
        directories     => $vhost_directories,
      }
    }
  }
}
