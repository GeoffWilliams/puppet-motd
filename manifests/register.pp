# Motd::Register
#
# Insert a message into the MOTD
define motd::register(
    $content=undef,
    $order=10
) {

  $body = pick($content, $name)

  concat::fragment{"motd_fragment_${name}":
    target  => "/etc/motd",
    content => $body,
  }
}
