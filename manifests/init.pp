# Class: motd
#
# This module manages the /etc/motd file using a template
#
# @param content [String] String to be used for motd
# @param issue_content [String] String to be used for `/etc/issue`
# @param issue_net_content [String] String to be used for `/etc/issue.net`
# @param identical_message [Boolean] If true, use the main MOTD message for all
#   messages unless overriden by `issue_content` and `issue_net`
#
# @example
#   include motd
#
# @example
#   class { "motd":
#     content => "\n\nNOTICE:\n\nThis Server is Managed by Puppet and is a \
#   Cowboy free zone!\nBeware that changes maybe overwritten without notice.\
#   \n\nInstalled Modules: ",
#   }
#
class motd (
  $content            = undef,
  $issue_content      = undef,
  $issue_net_content  = undef,
  Boolean $identical_message  = false,
) {

  $motd_content = pick($content, template('motd/motd.erb'))


  if $facts['kernel'] == 'Linux' {
    File {
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    $motd = '/etc/motd'
    if $identical_message {
      $default_content = template('motd/motd.erb')
    } else {
      $default_content = false
    }
    $_issue_content     = pick($issue_content, $default_content)
    $_issue_net_content = pick($issue_net_content, $default_content)


    concat { $motd:
      owner => 'root',
      group => 'root',
      mode  => '0644'
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

    concat::fragment{"motd_header":
      target  => $motd,
      content => $motd_content,
      order   => 01,
    }

    concat::fragment{"motd_footer":
      target  => $motd,
      content => "\n\n",
      order   => 99
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
  } elsif $facts['kernel'] == 'windows' {
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
  }
}
