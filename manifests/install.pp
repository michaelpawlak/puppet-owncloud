# == Class owncloud::install
#
# This class is called from owncloud for install.
#
class owncloud::install inherits ::owncloud {
  
  anchor { 'owncloud::install::begin': } ->
  class { 'owncloud::install::php5': } ->
  class { 'owncloud::install::apache': } ->
  class { 'owncloud::install::package': } ->
  class { 'owncloud::install::git': } ->
  class { 'owncloud::install::tarball': } ->
  class { 'owncloud::install::database': } ->
  class { 'owncloud::install::extras': } ->
  anchor { 'owncloud::install::end': }
}
