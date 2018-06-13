# Motd::Register
#
# Insert a message into the MOTD on Linux (has no function on Windows). Note that this only works with `/etc/motd`, not
# `/etc/issue` or `/etc/issue.net`
#
# @example Message before main MOTD
#   motd::register { "Hosted in Australia":}
#
# @example Message after main MOTD
#   motd::register { "Have a nice day":}
#
# @param title Content to use or unique identifier
# @param content Content to add to MOTD (defaults to title)
# @param order Position to add to `/etc/motd`
define motd::register(
    Optional[String]  $content  = undef,
    Optional[String]  $order    = "10",
) {

  $body = pick($content, $name)

  concat::fragment{"motd_fragment_${name}":
    target  => "/etc/motd",
    order   => $order,
    content => $body,
  }
}
