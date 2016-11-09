#!/usr/bin/env bats

@test "execute: zfs-snapshot-recursive.sh" {
  run ./zfs-snapshot-recursive.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "" ]
}
