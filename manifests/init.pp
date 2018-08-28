# @summary Setup the Message Of The Day on Windows and Linux.
#
# *Linux*
# Management of the files at:
#   * `/etc/motd`
#   * `/etc/issue`
#   * `/etc/issue.net`
#
# The `motd::register` defined type can also be used to add to to `/etc/motd` if desired.
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
#   motd::issue_content: "Please login"
#   motd::issue_net_content: "Nothing to see here"
#
# @param content The message to use for login message (or all messages) on all platforms or `false` to write an empty
#   file
# @param issue_content The message  to be used for `/etc/issue` (pre-login message - linux only) or `false` to write an
#   empty file
# @param issue_net_content The message to be used for `/etc/issue.net` (pre-login message for telnet/other nominated
#   services - linux only) or `false` to write an empty file
# @param identical_content `true` to use the main MOTD message from `content` for all messages unless overriden
#   individually by `issue_content` and `issue_net` (linux only)
class motd (
  Variant[Boolean, Optional[String]]  $content            = undef,
  Variant[Boolean, Optional[String]]  $issue_content      = undef,
  Variant[Boolean, Optional[String]]  $issue_net_content  = undef,
  Boolean                             $identical_content  = false,
) {

  # use supplied content if avaiable otherwise process our template for a generic message
  $motd_content = $content ? {
    Boolean => "",
    default => pick($content, epp('motd/motd.epp'))
  }

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

    file { '/etc/motd':
      ensure  => file,
      content => $motd_content,
    }

    if $identical_content {
      $default_content = $motd_content
    } else {
      $default_content = false
    }

    $_issue_content = $issue_content ? {
      Boolean => "",
      default => pick_default($issue_content, $default_content)
    }

    $_issue_net_content = $issue_net_content ? {
      Boolean => "",
      default => pick_default($issue_net_content, $default_content)
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
