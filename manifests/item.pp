# == Define Resource Type: vmail::item
#
# Private type, do not use on it's own.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
#
define vmail::item (
  # parent class / global configuration
  $file     = undef,
  $template = undef,
  $type     = undef,
  # prevent duplicate resource declaration
  $hash     = {}
) {

  include concat::setup
  include stdlib

  validate_hash($hash)
  validate_string($type)

  # Extract real $title
  $item = split($title, '#')[1]

  # Validate item
  if ( $item == undef or size($item) < 1 ) {
    fail("vmail::item[${title}]: failed to evaluate title")
  }

  # Generate user-specific configuration
  if $type == 'user' {
    if is_hash($hash['settings']) and $hash['settings']['maildir'] {
      $maildir = $hash['settings']['maildir']
    }
    else {
      $maildir = $item
    }
  }

  # Add a fragement to the pool.
  # XXX: This may generate a lot "no content" messages in Concat::Fragment.
  concat::fragment { "vmail::item ${title}":
    target  => $file,
    order   => '20',
    content => template($template),
  }

}
