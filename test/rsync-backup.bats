#!/usr/bin/env bats

@test "execute: rsync-backup.sh" {
  run ./rsync-backup.sh
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'The folders are not accessible or no affirmation file exists!' ]
}

@test "execute: rsync-backup.sh -h" {
  run ./rsync-backup.sh -h
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Usage: rsync-backup [-adefhlLmnNz] <source> <destination>' ]
}
