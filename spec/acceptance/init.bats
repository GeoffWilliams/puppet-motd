@test "default motd created from template" {
  grep 'Kernel' /etc/motd
}

@test "registered message works" {
  grep 'nice' /etc/motd
}
