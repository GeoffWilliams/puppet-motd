@test "default motd created from template" {
  grep 'Kernel' /etc/motd
}
