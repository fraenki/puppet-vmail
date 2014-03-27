# == Define Resource Type: vmail::postfix::dbfile
#
# This type will refresh database files on changes.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/stdlib module.
#
define vmail::postfix::dbfile (
  $file = undef,
  $type = 'lookup',
) {

  include stdlib
  validate_absolute_path($file)
  validate_string($type)

  case $::osfamily {
    'freebsd': {
      $postalias = '/usr/local/sbin/postalias'
      $postmap   = '/usr/local/sbin/postmap'
    }
    default:   {
      $postalias = '/usr/sbin/postalias'
      $postmap   = '/usr/sbin/postmap'
    }
  }

  $command = $type ? { 'alias' => $postalias, default => $postmap }

  exec { "${command} ${file}":
    cwd         => '/tmp',
    subscribe   => File[$file],
    refreshonly => true,
    # No need to notify the service, since it detects changed files
  }

}
