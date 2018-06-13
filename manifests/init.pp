# Class: motd
#
# Setup the Message Of The Day on Windows and Linux.
#
# *Linux*
# Management of the files at:
#   * `/etc/motd`
#   * `/etc/issue`
#   * `/etc/issue.net`
#
# A file will be created for you at `/etc/motd.local` which will be displayed to local users logging in via `/etc/motd`.
# You are free to write any content you like to this file. The `motd::register` defined type can also be used to add to
# to `/etc/motd` if desired.
#
# *Windows*
# On windows there is only one message which we write to registry key:
#   `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext`
#
# @see https://forge.puppet.com/puppetlabs/concat
#
# @example Default message
# If you do not supply the MOTD content, we will generate one for you from a template. Output will be similar to:
#   1f4ac00d071c (172.17.0.4)
#   ===============================================================================
#   CentOS 7.4.1708 x86_64
#
#   Processor: 8 x Intel(R) Core(TM) i7-6820HQ CPU @ 2.70GHz
#   Kernel:    4.15.0-22-generic
#   Memory:    31.27 GiB
#
# @example Use the generic MOTD from the template
#   include motd
#
# @example Setting MOTD for all files in one go
#   class { "motd":
#     content => "\n\nNOTICE:\n\nThis Server is Managed by Puppet and is a \
#   Cowboy free zone!\nBeware that changes maybe overwritten without notice.\
#   \n\nInstalled Modules: ",
#     identical_content => true,
#   }
#
# @example Hiera to set MOTD for all files in one go
#   motd::identical_content: true
#   motd::content: |
#     NOTICE:
#
#     This Server is Managed by Puppet and is a Cowboy free zone!
#     Beware that changes maybe overwritten without notice
#
# @example Hiera to set Messages individually:
#   motd::identical_content: true
#   motd::content: |
#     NOTICE:
#
#     This Server is Managed by Puppet and is a Cowboy free zone!
#     Beware that changes maybe overwritten without notice
#   motd::issue: "Please login"
#   motd::issue.net: "Nothing to see here"
#
# @param content The message to use for login message (or all messages) on all platforms
# @param issue_content The message  to be used for `/etc/issue` (pre-login message - linux only)
# @param issue_net_content The message to be used for `/etc/issue.net` (pre-login message for telnet/other nominated
#   services - linux only)
# @param identical_content `true` to use the main MOTD message from `content` for all messages unless overriden
#   individually by `issue_content` and `issue_net` (linux only)
class motd (
  Optional[String]  $content            = undef,
  Optional[String]  $issue_content      = undef,
  Optional[String]  $issue_net_content  = undef,
  Boolean           $identical_content  = false,
) {

  # use supplied content if avaiable otherwise process our template for a generic message
  $motd_content = pick($content, epp('motd/motd.epp'))

  if $facts['kernel'] == 'windows' {
    registry_value { 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption':
      ensure => present,
      type   => string,
      data   => 'Message of the day',
    }
    registry_value { 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext':
      ensure => present,
      type   => string,
      data   => $motd_content,
    }
  } else {

    # AIX officially needs to have ownership by `bin` according to many of the
    # audit guides out there.  Perhaps it needs this to write the file with a
    # message but I suspect this is just a "because I told you so" thing
    if $facts['kernel'] == 'AIX' {
      $owner = 'bin'
      $group = 'bin'
    } else {
      $owner = 'root'
      $group = 'root'
    }

    File {
      owner   => $owner,
      group   => $group,
      mode    => '0644',
    }

    $motd = '/etc/motd'
    if $identical_content {
      $default_content = $motd_content
    } else {
      $default_content = false
    }
    $_issue_content     = pick($issue_content, $default_content)
    $_issue_net_content = pick($issue_net_content, $default_content)


    concat { $motd:
      owner => $owner,
      group => $group,
      mode  => '0644'
    }

    concat::fragment{"motd_main":
      target  => $motd,
      content => $motd_content,
      order   => "05",
    }

    # let local users add to the motd by creating a file called
    # /etc/motd.local - NOTE that this message will only be shown
    # to LOCAL users via /etc/motd to prevent unwanted information
    # disclosure to those using ftp, etc
    file {'/etc/motd.local':
      ensure => file,
    }
    concat::fragment{ 'motd_local':
      target => $motd,
      source => '/etc/motd.local',
      order  => '15'
    }

    if $_issue_content {
      file { '/etc/issue':
        ensure  => file,
        content => $_issue_content,
      }
    }

    if $_issue_net_content {
      file { '/etc/issue.net':
        ensure  => file,
        content => $_issue_net_content,
      }
    }

  }
}
