# == Class owncloud::conf
#
# Puppet class to configure the owncloud application
# Class called from ::owncloud
#
class owncloud::conf inherits ::owncloud {

  # configure the owncloud application
  anchor { 'owncloud::conf::begin': } ->
  class { 'owncloud::conf::base': } ->
  class { 'owncloud::conf::autoconfig': } ->
  class { 'owncloud::conf::apache': } ->
  anchor { 'owncloud::conf::end': }
}
