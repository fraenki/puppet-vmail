# == Class: vmail::postfix
#
# This module creates all postfix data files, but does not manage
# the service, packages or main configuration files.
#
# === Examples
#
# $virtual_domains = hiera_hash('virtual_domains')
# $virtual_users   = hiera_hash('virtual_users')
#
#  class { 'vmail::postfix':
#    domain_hash => $virtual_domains,
#    user_hash   => $virtual_users,
#  }
#
class vmail::postfix (
  # required data
  $domain_hash = {},
  $user_hash   = {},
  # file configuration
  $group       = undef,
  $mode        = '0640',
  $owner       = 'root',
) {

  include stdlib

  validate_hash($domain_hash)
  validate_hash($user_hash)

  case $::osfamily {
    'FreeBSD': {
      $my_group   = $group ? { undef  => 'wheel', default => $group }
      $postfixdir = '/usr/local/etc/postfix'
    }
    default: {
      $my_group   = $group ? { undef  => 'root', default => $group }
      $postfixdir = '/etc/postfix'
    }
  }

  vmail::file { "${postfixdir}/aliases":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/aliases",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/aliases.erb',
    user_hash   => $user_hash,
  }

  vmail::postfix::dbfile { "${postfixdir}/aliases":
    file => "${postfixdir}/aliases",
    type => 'alias',
  }

  vmail::file { "${postfixdir}/canonical":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/canonical",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/canonical.erb',
    user_hash   => $user_hash,
  }

  vmail::postfix::dbfile { "${postfixdir}/canonical":
    file => "${postfixdir}/canonical",
  }

  vmail::file { "${postfixdir}/relay_domains":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/relay_domains",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/relay_domains.erb',
    user_hash   => $user_hash,
  }

  vmail::file { "${postfixdir}/transport":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/transport",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/transport.erb',
    user_hash   => $user_hash,
  }

  vmail::postfix::dbfile { "${postfixdir}/transport":
    file => "${postfixdir}/transport",
  }

  vmail::file { "${postfixdir}/virtual":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/virtual",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/virtual.erb',
    user_hash   => $user_hash,
  }

  vmail::postfix::dbfile { "${postfixdir}/virtual":
    file => "${postfixdir}/virtual",
  }

  vmail::file { "${postfixdir}/virtual_alias":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/virtual_alias",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/virtual_alias.erb',
    user_hash   => $user_hash,
  }

  vmail::postfix::dbfile { "${postfixdir}/virtual_alias":
    file => "${postfixdir}/virtual_alias",
  }

  vmail::file { "${postfixdir}/virtual_domains":
    domain_hash => $domain_hash,
    file        => "${postfixdir}/virtual_domains",
    group       => $my_group,
    owner       => $owner,
    template    => 'vmail/postfix/virtual_domains.erb',
    user_hash   => $user_hash,
  }

}
