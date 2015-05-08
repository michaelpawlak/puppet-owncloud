# == Class: owncloud::install::database
#
# Puppet class to configure database for owncloud.
# Class called from ::owncloud::install
#
class owncloud::install::database inherits ::owncloud::install {
  # install the mysql database on localhost
  if $manage_db {
    if $db_type == 'mysql' {
      if $db_host == 'localhost' {
        
        # include the mysql module
        include ::mysql::server

        # create the mysql db on localhost
        mysql::db { "${db_name}":
          user     => $db_user,
          password => $db_pass,
          host     => $db_host,
          grant    => ['ALL'],
        }
      }
    }
  }
}