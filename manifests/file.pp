# == Define Resource Type: vmail::file
#
# This type will create a file by using the provided hash and template.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
#
define vmail::file (
  $domain_hash = {},
  $file        = undef,
  $group       = 'root',
  $mode        = '0644',
  $owner       = 'root',
  $template    = undef,
  $user_hash   = {},
) {

  include concat::setup
  include stdlib

  validate_hash($domain_hash)
  validate_absolute_path($file)
  validate_string($template)
  validate_hash($user_hash)

  # Title must not collide with our separator
  if $title =~ /.*\#.*/ {
    fail("vmail::file[${title}]: 'title' must not contain the '#' sign")
  }

  concat { $file:
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  # The $target file must never be empty, or we'll see concat errors.
  concat::fragment { "vmail header ${file} ${title}":
    target  => $file,
    order   => '10',
    content => template('vmail/header.erb'),
  }

  # Add a prefix to the domain name to prevent duplicate resource declarations.
  each($domain_hash) |$domain, $options| {
    # Domain name must not collide with our separator
    if $domain =~ /.*\#.*/ {
      fail("vmail::file[${title}][${domain}]: domain name must not contain the '#' sign")
    }

    # Check required host
    if is_hash($options) and is_array($options['hosts']) {
      # Validate against node FQDN
      if !member($options['hosts'], $::fqdn) {
        $force_disabled = true
      }
    }

    if $force_disabled != true {
      # Instantiate
      vmail::item { "${title}#${domain}":
        file      => $file,
        hash      => $options,
        template  => $template,
        type      => 'domain',
      }
    }
  }

  # Add a prefix to the user name to prevent duplicate resource declarations.
  each($user_hash) |$user, $options| {
    # Username must not collide with our separator
    if $user =~ /.*\#.*/ {
      fail("vmail::file[${title}][${user}]: username must not contain the '#' sign")
    }

    # Instantiate
    vmail::item { "${title}#${user}":
      file      => $file,
      hash      => $options,
      template  => $template,
      type      => 'user',
    }
  }
}
