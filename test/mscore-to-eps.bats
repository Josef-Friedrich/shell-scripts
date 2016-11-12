#!/usr/bin/env bats

@test "execute: mscore-to-eps.sh" {
  run ./mscore-to-eps.sh test/mscore-to-eps/no-mscore
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "No files to convert found!" ]
}

@test "execute: mscore-to-eps.sh -h" {
  run ./mscore-to-eps.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: mscore-to-eps.sh [-h] [<musescore-file>]" ]
}

@test "execute: mscore-to-eps.sh test/mscore-to-eps/single-page.mscx" {
  if [ "$TRAVIS" = 'true' ]; then skip ; fi
  run ./mscore-to-eps.sh test/mscore-to-eps/single-page.mscx
  [ "$status" -eq 0 ]
}
