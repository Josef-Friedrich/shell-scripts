#!/usr/bin/env bats

@test "execute: maillog.sh" {
  run ./maillog.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: maillog.sh [-b BODY ] <subject> <text-file-to-send>" ]
}

@test "execute: maillog.sh -h" {
  run ./maillog.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: maillog.sh [-b BODY ] <subject> <text-file-to-send>" ]
}
