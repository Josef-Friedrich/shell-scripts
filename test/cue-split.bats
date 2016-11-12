#!/usr/bin/env bats

@test "execute: cue-split.sh" {
  run ./cue-split.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Error: Found no files to split!' ]
}

@test "execute: cue-split.sh -h" {
  run ./cue-split.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Usage: cue-split.sh [<path>]' ]
}
