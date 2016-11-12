#!/usr/bin/env bats

@test "execute: mscore-to-eps.sh" {
  run ./mscore-to-eps.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "No files to convert found!" ]
}

@test "execute: mscore-to-eps.sh -h" {
  run ./mscore-to-eps.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: mscore-to-eps.sh [-h] [<musescore-file>]" ]
}
