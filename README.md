#vmail

##Table of Contents

- [Overview](#overview)
- [Module Description](#module-description)
- [Requirements](#requirements)
  - [Experimental Feature](#experimental-feature)
  - [Dependencies](#dependencies)
- [Usage](#usage)
  - [Setup HIERA: _Simple example (YAML)_](#setup-hiera-_simple-example-yaml_)
  - [Setup HIERA: _Complex example (YAML)_](#setup-hiera-_complex-example-yaml_)
  - [Basic Usage](#basic-usage)
  - [Complex Example](#complex-example)
- [Reference](#reference)
  - [Feature overview](#feature-overview)
  - [HIERA attribute reference](#hiera-attribute-reference)
  - [Module parameter reference](#module-parameter-reference)
  - [Performance](#performance)
  - [Iterations/Lambdas](#iterationslambdas)
- [Development](#development)

##Overview

This module manages data-driven mail configuration files. It does NOT manage the mail service itself.

##Module Description

You define your mail environment in HIERA - domains, addresses, routes, policies - and _vmail_ will put this data in application-specific files. Its focus is on DATA.

Features:

* Use HIERA to define your mail environment
* Choose from pre-defined schemes (currently only Postfix)
* Contribute! Create schemes for other MTAs

Currently only file-backends are supported, but it should be possible to support other backends/databases as well.

NOTE: To manage passwd-like virtual user databases, you may want to checkout the _vpasswd_ module.

##Requirements

Unlike many modules, _vmail_ does not manage your mail service nor will it try to install any package. You need additional modules to manage your MTAs main configuration and service.

###Experimental Feature

This module requires iterations/lambdas. You need puppet 3.2+ and the future parser enabled in order to use this module.

###Dependencies

Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
I recommend to use my _vpasswd_ module for virtual user and e-mail address management.
Besides that _thias-postfix_ and _jproyo-dovecot_ are useful to manage the mail services.

##Usage

First, you need to define your mail environment in HIERA. While this module tries to be as flexible as possible, it requires you to use the expected syntax.

###Setup HIERA: _Simple example (YAML)_

    virtual_domains:
      company.com:
        aliases: [the-company.com, company.org, mycompany.net]
      thecompany.co.uk:
      theproduct.com:

NOTE: This example does not cover the user configuration. You may want to have a look at the _vpasswd_ module for an example user configuration.

###Setup HIERA: _Complex example (YAML)_

    virtual_domains:
      company.com:
        aliases: [the-company.com, company.org, mycompany.net]
        masquerades: [www.company.com, mx1.company.com, mx2.company.com]
      thecompany.co.uk:
      theproduct.com:
      example.com:
        hosts: [mx3.company.com, mx4.company.com]
      customer1.com:
        type: backupmx
      customer2.com:
        type: backupmx
        hosts: [mx3.company.com, mx4.company.com]
      portal.company.com:
        type: relay
        host: mx-int.company.com
      test.company.com:
        type: relay
        host: mx-test.company.com
        port: 2525

NOTE: This example does not cover the user configuration. You may want to have a look at the _vpasswd_ module for an example user configuration.

###Basic Usage

The most basic, yet fully-working example:

    $virtual_domains = hiera_hash('virtual_domains')
    $virtual_accounts = hiera_hash('virtual_accounts')

    class { 'vmail::postfix':
      domain_hash => $virtual_domains,
      user_hash   => $virtual_accounts,
    }

This will create a bunch of files for postfix:

* aliases(.db)
* canonical(.db)
* relay_domains
* relocated(.db)
* transport(.db)
* virtual(.db)
* virtual_alias(.db)
* virtual_domains

###Complex Example

You may want to customize the whole thing by using  _vmail::file_ directly:

    $virtual_domains = hiera_hash('my_domains')
    $virtual_accounts = hiera_hash('my_accounts')

    $postfixdir = '/foo/postfix/instance3/conf'

    vmail::file { "${postfixdir}/virtual_alias":
      domain_hash => $virtual_domains,
      file        => "${postfixdir}/virtual_alias",
      group       => 'mail_instance3',
      owner       => 'mail_instance3',
      template    => 'vmail/postfix/virtual_alias.erb',
      user_hash   => $virtual_accounts,
    }

    vmail::postfix::dbfile { "${postfixdir}/virtual_alias":
      file     => "${postfixdir}/virtual_alias",
    }

##Reference

###Feature overview

Configure domain aliases:

    company.com:
      aliases: [the-company.com, company.org, mycompany.net]

Tie a domain configuration to specific hosts:

    company.com:
      hosts: [mx3.company.com, mx4.company.com]

Create a backup MX configuration:

    company.com:
      type: backupmx

Relay mail to a specific host (and optional port):

    company.com:
      type: relay
      host: mx-test.company.com
      port: 2525

###HIERA attribute reference

All currently supported attributes:

    virtual_domains:
      company.com:
        aliases: [the-company.com, company.org, mycompany.net]
        masquerades: [www.company.com, mx1.company.com, mx2.company.com]
      example.com:
        hosts: [mx3.company.com, mx4.company.com]
      customer1.com:
        type: backupmx
      portal.company.com:
        type: relay
        host: mx-int.company.com
      test.company.com:
        type: relay
        host: mx-test.company.com
        port: 2525

###Module parameter reference

All currently supported parameters:

    class { 'vmail::postfix':
      domain_hash => $virtual_domains,
      user_hash   => $virtual_accounts,
    }

    vmail::file { "postfix virtual_alias file":
      domain_hash => $virtual_domains,
      file        => '/foo/postfix/virtual_alias',
      group       => 'mail',
      owner       => 'mail',
      template    => 'vmail/postfix/virtual_alias.erb',
      user_hash   => $virtual_accounts,
    }

    vmail::postfix::dbfile { "virtual_alias":
      file     => '/foo/postfix/virtual_alias',
    }

###Performance

This module does not scale well. The performance suffers from the _future parser_ and the large number of objects being created during a puppet run, or maybe it's the concat module. If you find a way to improve performance, please let me know.

###Iterations/Lambdas

Why does this module depend on experimental features like iterations/lambdas? I wanted to keep the defined types simple, but still make it possible to use the same mail data multiple times (for multiple files, multiple applications). To avoid duplicate declarations I needed to use iterations (and unique names for every object, hence separators were born).

##Development

Please use the github issues functionality to report any bugs or requests for new features.
Feel free to fork and submit pull requests for potential contributions.
