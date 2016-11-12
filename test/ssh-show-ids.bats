#!/usr/bin/env bats

@test "execute: ssh-show-ids.sh" {
  run ./ssh-show-ids.sh
  [ "$status" -eq 0 ]
}
