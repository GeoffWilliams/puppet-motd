@test "/etc/motd empty" {
  [[ ! -s /etc/motd ]]
}

@test "/etc/issue.net" {
  grep "issue_net" /etc/issue.net
}

@test "/etc/issue" {
  grep "issue" /etc/issue
}