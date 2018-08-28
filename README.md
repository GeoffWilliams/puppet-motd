[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-motd.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-motd)
# motd

#### Table of Contents

1. [Description](#description)
1. [Features](#features)
1. [Puppet resource implementation](#puppet-resource-implementation)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage MOTD with puppet.
 
## Features

Write to some or all of:

* `/etc/motd` 
* `/etc/issue` 
* `/etc/issue.net`


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
