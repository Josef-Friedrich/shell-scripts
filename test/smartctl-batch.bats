#!/usr/bin/env bats

@test "execute: smartctl-batch.sh" {
  skip
  run ./smartctl-batch.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "" ]
}
