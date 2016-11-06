#!/usr/bin/env bats

@test "execute: mscore-export-eps.sh" {
  run ./mscore-export-eps.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "No files to convert found!" ]
}

@test "execute: mscore-export-eps.sh -h" {
  run ./mscore-export-eps.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: mscore-export-eps.sh [-h] [<musescore-file>]" ]
}
