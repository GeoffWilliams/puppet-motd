[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-motd.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-motd)
# motd

#### Table of Contents

1. [Description](#description)
1. [Features](#features)
1. [Puppet resource implementation](#puppet-resource-implementation)
1. [motd precedence](#motd-precedence)
1. [Value handling](#value-handling)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](REFERENCE.md)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage MOTD with puppet in the files:

* `/etc/motd` 
* `/etc/issue` 
* `/etc/issue.net`

## Reference
[generated documentation](https://rawgit.com/GeoffWilliams/puppet-motd/master/doc/index.html).

Reference documentation is generated directly from source code using [puppet-strings](https://github.com/puppetlabs/puppet-strings).  You may regenerate the documentation by running:

```shell
bundle exec puppet strings
```

## Limitations
*   Tested on RHEL/CentOS 7 so far. You might be able to support other systems by passing the appropriate command to 
    rebuild initrd on your platform

## Development

PRs accepted :)

## Testing
This module supports testing using [PDQTest](https://github.com/declarativesystems/pdqtest).


Test can be executed with:

```
bundle install
make
```

See `.travis.yml` for a working CI example
